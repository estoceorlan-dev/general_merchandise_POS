import {randomUUID} from "crypto";
import {PoolClient} from "pg";

type MembershipRow = {
  app_user_id: string;
  email: string;
  display_name: string;
  status: string;
  organization_id: string;
  organization_code: string;
  organization_name: string;
  organization_timezone: string;
};

type RoleRow = {
  branch_id: string | null;
  role_id: string;
  role_code: string;
  role_name: string;
  permission_codes: string[];
};

type BranchRow = {
  id: string;
  code: string;
  name: string;
  timezone: string;
};

const temporaryAdminEmail = "estoce.orlan@gmail.com";
const temporaryAdminDisplayName = "Jce-Admin";
const adminRoleCode = "admin";
const adminRoleName = "Admin";
const defaultOrganizationCode = "JCE";
const defaultOrganizationName = "JCE General Merchandise";
const defaultBranchCode = "MAIN";
const defaultBranchName = "Main Branch";
const defaultTimezone = "Asia/Manila";
const adminPermissionCodes = [
  "dashboard.view",
  "sales.process",
  "products.manage",
  "inventory.manage",
  "transfers.approve",
  "purchases.create",
  "reports.view",
  "audit_logs.view",
  "users.manage",
  "settings.manage",
];

export class AccessProfileDeniedError extends Error {
  constructor(readonly reason: "not-found" | "inactive") {
    super(reason);
  }
}

export async function bootstrapTemporaryAdminAccessProfile(
  client: PoolClient,
  input: {
    firebaseUid: string;
    email: string;
  },
): Promise<Record<string, unknown>> {
  const normalizedEmail = input.email.trim().toLowerCase();
  if (normalizedEmail !== temporaryAdminEmail) {
    throw new AccessProfileDeniedError("not-found");
  }

  await client.query("BEGIN");
  try {
    const organizationId = await resolveBootstrapOrganization(client);
    await ensureBootstrapBranch(client, organizationId);
    const roleId = await resolveBootstrapAdminRole(client, organizationId);
    await replaceBootstrapAdminPermissions(client, roleId);
    const appUserId = await resolveBootstrapAdminUser(client, {
      organizationId,
      firebaseUid: input.firebaseUid,
      email: normalizedEmail,
    });
    await ensureBootstrapAdminAssignment(client, {
      organizationId,
      appUserId,
      roleId,
    });
    await client.query("COMMIT");
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  }

  return loadAccessProfile(client, input.firebaseUid, normalizedEmail);
}

export async function loadAccessProfile(
  client: PoolClient,
  firebaseUid: string,
  tokenEmail?: string,
): Promise<Record<string, unknown>> {
  const memberships = await client.query<MembershipRow>(
    `
      SELECT
        au.id AS app_user_id,
        au.email,
        au.display_name,
        au.status,
        o.id AS organization_id,
        o.code AS organization_code,
        o.name AS organization_name,
        o.timezone AS organization_timezone
      FROM app_users au
      INNER JOIN organizations o ON o.id = au.organization_id
      WHERE au.firebase_uid = $1
        AND au.deleted_at IS NULL
        AND o.deleted_at IS NULL
        AND o.is_active = true
      ORDER BY o.name, au.id
    `,
    [firebaseUid],
  );

  if (memberships.rowCount === 0) {
    throw new AccessProfileDeniedError("not-found");
  }

  const activeMemberships = memberships.rows.filter(
    (membership) => membership.status === "active",
  );
  if (activeMemberships.length === 0) {
    throw new AccessProfileDeniedError("inactive");
  }

  const organizations = [];
  for (const membership of activeMemberships) {
    const roles = await client.query<RoleRow>(
      `
        SELECT
          ura.branch_id,
          r.id AS role_id,
          r.code AS role_code,
          r.name AS role_name,
          COALESCE(
            array_agg(rp.permission_code ORDER BY rp.permission_code)
              FILTER (WHERE rp.permission_code IS NOT NULL),
            ARRAY[]::text[]
          ) AS permission_codes
        FROM user_role_assignments ura
        INNER JOIN roles r ON r.id = ura.role_id
        LEFT JOIN role_permissions rp ON rp.role_id = r.id
        WHERE ura.user_id = $1
          AND ura.organization_id = $2
          AND ura.revoked_at IS NULL
          AND r.is_active = true
          AND r.deleted_at IS NULL
        GROUP BY ura.id, ura.branch_id, r.id, r.code, r.name
        ORDER BY r.name, r.id
      `,
      [membership.app_user_id, membership.organization_id],
    );

    const branches = await client.query<BranchRow>(
      `
        SELECT b.id, b.code, b.name, b.timezone
        FROM branches b
        WHERE b.organization_id = $1
          AND b.is_active = true
          AND b.deleted_at IS NULL
          AND (
            EXISTS (
              SELECT 1
              FROM user_role_assignments organization_assignment
              WHERE organization_assignment.user_id = $2
                AND organization_assignment.organization_id = b.organization_id
                AND organization_assignment.branch_id IS NULL
                AND organization_assignment.revoked_at IS NULL
            )
            OR EXISTS (
              SELECT 1
              FROM user_role_assignments branch_assignment
              WHERE branch_assignment.user_id = $2
                AND branch_assignment.organization_id = b.organization_id
                AND branch_assignment.branch_id = b.id
                AND branch_assignment.revoked_at IS NULL
            )
          )
        ORDER BY b.name, b.id
      `,
      [membership.organization_id, membership.app_user_id],
    );

    const rolePayload = (role: RoleRow) => ({
      id: role.role_id,
      code: role.role_code,
      name: role.role_name,
      permissions: role.permission_codes,
    });
    organizations.push({
      appUserId: membership.app_user_id,
      status: membership.status,
      organization: {
        id: membership.organization_id,
        code: membership.organization_code,
        name: membership.organization_name,
        timezone: membership.organization_timezone,
      },
      organizationRoles: roles.rows
        .filter((role) => role.branch_id === null)
        .map(rolePayload),
      branches: branches.rows.map((branch) => ({
        branch: {
          id: branch.id,
          code: branch.code,
          name: branch.name,
          timezone: branch.timezone,
        },
        roles: roles.rows
          .filter((role) => role.branch_id === branch.id)
          .map(rolePayload),
      })),
    });
  }

  const firstMembership = activeMemberships[0];
  return {
    user: {
      firebaseUid,
      email: firstMembership.email || tokenEmail,
      displayName: firstMembership.display_name,
    },
    organizations,
  };
}

export async function registerDeviceForUser(
  client: PoolClient,
  input: {
    firebaseUid: string;
    deviceId: string;
    platform: string;
    organizationId: string;
    branchId: string;
  },
): Promise<void> {
  const membership = await client.query<{app_user_id: string}>(
    `
      SELECT au.id AS app_user_id
      FROM app_users au
      INNER JOIN organizations o ON o.id = au.organization_id
      INNER JOIN branches b
        ON b.id = $3
       AND b.organization_id = au.organization_id
      WHERE au.firebase_uid = $1
        AND au.organization_id = $2
        AND au.status = 'active'
        AND au.deleted_at IS NULL
        AND o.is_active = true
        AND o.deleted_at IS NULL
        AND b.is_active = true
        AND b.deleted_at IS NULL
        AND EXISTS (
          SELECT 1
          FROM user_role_assignments ura
          WHERE ura.user_id = au.id
            AND ura.organization_id = au.organization_id
            AND (ura.branch_id IS NULL OR ura.branch_id = b.id)
            AND ura.revoked_at IS NULL
        )
      LIMIT 1
    `,
    [input.firebaseUid, input.organizationId, input.branchId],
  );
  if (membership.rowCount !== 1) {
    throw new AccessProfileDeniedError("not-found");
  }

  const result = await client.query(
    `
      INSERT INTO devices (
        id,
        organization_id,
        branch_id,
        user_id,
        platform,
        last_seen_at,
        registered_at,
        disabled_at
      )
      VALUES ($1, $2, $3, $4, $5, now(), now(), NULL)
      ON CONFLICT (organization_id, id) DO UPDATE SET
        branch_id = EXCLUDED.branch_id,
        platform = EXCLUDED.platform,
        last_seen_at = now(),
        disabled_at = NULL
      WHERE devices.user_id = EXCLUDED.user_id
      RETURNING id
    `,
    [
      input.deviceId,
      input.organizationId,
      input.branchId,
      membership.rows[0].app_user_id,
      input.platform,
    ],
  );
  if (result.rowCount !== 1) {
    throw new AccessProfileDeniedError("not-found");
  }
}

export async function updateBranchNameForUser(
  client: PoolClient,
  input: {
    firebaseUid: string;
    organizationId: string;
    branchId: string;
    name: string;
  },
): Promise<void> {
  const result = await client.query(
    `
      UPDATE branches b
      SET name = $4, updated_at = now()
      WHERE b.id = $3
        AND b.organization_id = $2
        AND b.is_active = true
        AND b.deleted_at IS NULL
        AND EXISTS (
          SELECT 1
          FROM app_users au
          INNER JOIN user_role_assignments ura ON ura.user_id = au.id
          INNER JOIN roles r ON r.id = ura.role_id
          INNER JOIN role_permissions rp ON rp.role_id = r.id
          WHERE au.firebase_uid = $1
            AND au.organization_id = b.organization_id
            AND au.status = 'active'
            AND au.deleted_at IS NULL
            AND ura.revoked_at IS NULL
            AND (ura.branch_id IS NULL OR ura.branch_id = b.id)
            AND r.is_active = true
            AND r.deleted_at IS NULL
            AND rp.permission_code = 'settings.manage'
        )
      RETURNING b.id
    `,
    [
      input.firebaseUid,
      input.organizationId,
      input.branchId,
      input.name,
    ],
  );
  if (result.rowCount !== 1) {
    throw new AccessProfileDeniedError("not-found");
  }
}

async function resolveBootstrapOrganization(
  client: PoolClient,
): Promise<string> {
  const existing = await client.query<{id: string}>(
    `
      SELECT id
      FROM organizations
      WHERE code = $1
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [defaultOrganizationCode],
  );
  if (existing.rowCount === 1) {
    await client.query(
      `
        UPDATE organizations
        SET is_active = true,
            updated_at = now(),
            deleted_at = NULL
        WHERE id = $1
      `,
      [existing.rows[0].id],
    );
    return existing.rows[0].id;
  }

  const active = await client.query<{id: string}>(
    `
      SELECT id
      FROM organizations
      WHERE is_active = true
        AND deleted_at IS NULL
      ORDER BY name, id
      LIMIT 1
    `,
  );
  if (active.rowCount === 1) {
    return active.rows[0].id;
  }

  const organizationId = randomUUID();
  await client.query(
    `
      INSERT INTO organizations (
        id,
        code,
        name,
        timezone,
        is_active,
        created_at,
        updated_at,
        deleted_at
      )
      VALUES ($1, $2, $3, $4, true, now(), now(), NULL)
    `,
    [
      organizationId,
      defaultOrganizationCode,
      defaultOrganizationName,
      defaultTimezone,
    ],
  );
  return organizationId;
}

async function ensureBootstrapBranch(
  client: PoolClient,
  organizationId: string,
): Promise<string> {
  const active = await client.query<{id: string}>(
    `
      SELECT id
      FROM branches
      WHERE organization_id = $1
        AND is_active = true
        AND deleted_at IS NULL
      ORDER BY name, id
      LIMIT 1
    `,
    [organizationId],
  );
  if (active.rowCount === 1) {
    return active.rows[0].id;
  }

  const branchId = randomUUID();
  await client.query(
    `
      INSERT INTO branches (
        id,
        organization_id,
        code,
        name,
        timezone,
        is_active,
        created_at,
        updated_at,
        deleted_at
      )
      VALUES ($1, $2, $3, $4, $5, true, now(), now(), NULL)
    `,
    [
      branchId,
      organizationId,
      defaultBranchCode,
      defaultBranchName,
      defaultTimezone,
    ],
  );
  return branchId;
}

async function resolveBootstrapAdminRole(
  client: PoolClient,
  organizationId: string,
): Promise<string> {
  const existing = await client.query<{id: string}>(
    `
      SELECT id
      FROM roles
      WHERE organization_id = $1
        AND code = $2
      LIMIT 1
    `,
    [organizationId, adminRoleCode],
  );
  if (existing.rowCount === 1) {
    await client.query(
      `
        UPDATE roles
        SET name = $2,
            description = $3,
            is_active = true,
            updated_at = now(),
            deleted_at = NULL
        WHERE id = $1
      `,
      [
        existing.rows[0].id,
        adminRoleName,
        "Full-permission temporary admin role.",
      ],
    );
    return existing.rows[0].id;
  }

  const roleId = randomUUID();
  await client.query(
    `
      INSERT INTO roles (
        id,
        organization_id,
        code,
        name,
        description,
        is_active,
        created_at,
        updated_at,
        deleted_at
      )
      VALUES ($1, $2, $3, $4, $5, true, now(), now(), NULL)
    `,
    [
      roleId,
      organizationId,
      adminRoleCode,
      adminRoleName,
      "Full-permission temporary admin role.",
    ],
  );
  return roleId;
}

async function replaceBootstrapAdminPermissions(
  client: PoolClient,
  roleId: string,
): Promise<void> {
  await client.query("DELETE FROM role_permissions WHERE role_id = $1", [
    roleId,
  ]);
  for (const permissionCode of adminPermissionCodes) {
    await client.query(
      `
        INSERT INTO permissions (code, name, created_at)
        VALUES ($1, $1, now())
        ON CONFLICT (code) DO UPDATE SET
          name = EXCLUDED.name
      `,
      [permissionCode],
    );
    await client.query(
      `
        INSERT INTO role_permissions (role_id, permission_code, granted_at)
        VALUES ($1, $2, now())
      `,
      [roleId, permissionCode],
    );
  }
}

async function resolveBootstrapAdminUser(
  client: PoolClient,
  input: {
    organizationId: string;
    firebaseUid: string;
    email: string;
  },
): Promise<string> {
  const existingByEmail = await client.query<{id: string}>(
    `
      SELECT id
      FROM app_users
      WHERE organization_id = $1
        AND email = $2
      LIMIT 1
    `,
    [input.organizationId, input.email],
  );
  const existingByFirebaseUid = await client.query<{id: string}>(
    `
      SELECT id
      FROM app_users
      WHERE organization_id = $1
        AND firebase_uid = $2
      LIMIT 1
    `,
    [input.organizationId, input.firebaseUid],
  );
  const appUserId =
    existingByEmail.rows[0]?.id ??
    existingByFirebaseUid.rows[0]?.id ??
    randomUUID();

  await client.query(
    `
      INSERT INTO app_users (
        id,
        organization_id,
        firebase_uid,
        email,
        display_name,
        status,
        created_at,
        updated_at,
        deleted_at
      )
      VALUES ($1, $2, $3, $4, $5, 'active', now(), now(), NULL)
      ON CONFLICT (id) DO UPDATE SET
        firebase_uid = EXCLUDED.firebase_uid,
        email = EXCLUDED.email,
        display_name = EXCLUDED.display_name,
        status = 'active',
        updated_at = now(),
        deleted_at = NULL
    `,
    [
      appUserId,
      input.organizationId,
      input.firebaseUid,
      input.email,
      temporaryAdminDisplayName,
    ],
  );
  return appUserId;
}

async function ensureBootstrapAdminAssignment(
  client: PoolClient,
  input: {
    organizationId: string;
    appUserId: string;
    roleId: string;
  },
): Promise<void> {
  await client.query(
    `
      INSERT INTO user_role_assignments (
        id,
        organization_id,
        branch_id,
        user_id,
        role_id,
        assigned_at,
        revoked_at
      )
      VALUES ($1, $2, NULL, $3, $4, now(), NULL)
      ON CONFLICT (id) DO UPDATE SET
        revoked_at = NULL
    `,
    [
      `${input.appUserId}:organization:${input.roleId}`,
      input.organizationId,
      input.appUserId,
      input.roleId,
    ],
  );
}
