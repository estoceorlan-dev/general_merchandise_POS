const fs = require("node:fs/promises");
const path = require("node:path");
const {Client} = require("pg");

async function main() {
  const connectionString = process.env.JCE_DATABASE_URL?.trim();
  if (!connectionString) {
    throw new Error("JCE_DATABASE_URL is required.");
  }

  const schemaPath = path.resolve(
    __dirname,
    "..",
    "..",
    "sql",
    "phase_2_access_control.sql",
  );
  const sql = await fs.readFile(schemaPath, "utf8");
  const client = new Client({connectionString});
  await client.connect();
  try {
    await client.query(sql);
    const result = await client.query(
      `
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = ANY($1::text[])
        ORDER BY table_name
      `,
      [[
        "app_users",
        "branches",
        "devices",
        "organizations",
        "permissions",
        "role_permissions",
        "roles",
        "user_role_assignments",
      ]],
    );
    if (result.rowCount !== 8) {
      throw new Error(
        `Schema verification found ${result.rowCount ?? 0} of 8 tables.`,
      );
    }
    console.log("Phase 2 schema applied and verified.");
  } finally {
    await client.end();
  }
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
