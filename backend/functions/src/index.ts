import {initializeApp} from "firebase-admin/app";
import {logger} from "firebase-functions";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {defineString} from "firebase-functions/params";

import {
  AccessProfileDeniedError,
  bootstrapTemporaryAdminAccessProfile,
  loadAccessProfile,
  registerDeviceForUser,
  updateBranchNameForUser,
} from "./access_profile";
import {withDatabase} from "./database";

initializeApp();

const functionsRegion = defineString("JCE_FUNCTIONS_REGION", {
  default: "asia-southeast1",
});
const databaseInstanceConnectionName = defineString(
  "JCE_DB_INSTANCE_CONNECTION_NAME",
  {
    default: "jce-pos:asia-southeast1:jce-pos-instance",
  },
);
const databaseName = defineString("JCE_DB_NAME", {
  default: "jce-pos-database",
});
const databaseUser = defineString("JCE_DB_USER", {
  default: "jce-pos@appspot",
});
const runtimeServiceAccount = defineString("JCE_FUNCTIONS_SERVICE_ACCOUNT", {
  default: "jce-pos@appspot.gserviceaccount.com",
});

export const getMyAccessProfile = onCall(
  {
    region: functionsRegion,
    serviceAccount: runtimeServiceAccount,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (uid === undefined) {
      throw new HttpsError("unauthenticated", "Authentication is required.");
    }

    try {
      return await withDatabase(databaseConfig(), (client) =>
        loadAccessProfile(
          client,
          uid,
          typeof request.auth?.token.email === "string"
            ? request.auth.token.email
            : undefined,
        ),
      );
    } catch (error) {
      if (error instanceof AccessProfileDeniedError) {
        throw new HttpsError(
          error.reason === "not-found" ? "not-found" : "permission-denied",
          "No active JCE POS access profile is available.",
        );
      }
      logger.error("Access profile lookup failed.", error);
      throw new HttpsError("internal", "Access profile lookup failed.");
    }
  },
);

export const bootstrapTemporaryAdmin = onCall(
  {
    region: functionsRegion,
    serviceAccount: runtimeServiceAccount,
  },
  async (request) => {
    const uid = request.auth?.uid;
    const email =
      typeof request.auth?.token.email === "string"
        ? request.auth.token.email
        : undefined;
    if (uid === undefined || email === undefined) {
      throw new HttpsError("unauthenticated", "Authentication is required.");
    }

    try {
      return await withDatabase(databaseConfig(), (client) =>
        bootstrapTemporaryAdminAccessProfile(client, {
          firebaseUid: uid,
          email,
        }),
      );
    } catch (error) {
      if (error instanceof AccessProfileDeniedError) {
        throw new HttpsError(
          "permission-denied",
          "The temporary admin bootstrap is not available for this account.",
        );
      }
      logger.error("Temporary admin bootstrap failed.", error);
      throw new HttpsError("internal", "Temporary admin bootstrap failed.");
    }
  },
);

export const registerDevice = onCall(
  {
    region: functionsRegion,
    serviceAccount: runtimeServiceAccount,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (uid === undefined) {
      throw new HttpsError("unauthenticated", "Authentication is required.");
    }

    const deviceId = requiredString(request.data, "deviceId");
    const platform = requiredString(request.data, "platform");
    const organizationId = requiredString(request.data, "organizationId");
    const branchId = requiredString(request.data, "branchId");

    try {
      await withDatabase(databaseConfig(), (client) =>
        registerDeviceForUser(client, {
          firebaseUid: uid,
          deviceId,
          platform,
          organizationId,
          branchId,
        }),
      );
      return {registered: true};
    } catch (error) {
      if (error instanceof AccessProfileDeniedError) {
        throw new HttpsError(
          "permission-denied",
          "The device cannot be registered for this branch.",
        );
      }
      logger.error("Device registration failed.", error);
      throw new HttpsError("internal", "Device registration failed.");
    }
  },
);

export const updateBranchName = onCall(
  {
    region: functionsRegion,
    serviceAccount: runtimeServiceAccount,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (uid === undefined) {
      throw new HttpsError("unauthenticated", "Authentication is required.");
    }

    const organizationId = requiredString(request.data, "organizationId");
    const branchId = requiredString(request.data, "branchId");
    const name = requiredString(request.data, "name");
    if (name.length < 2 || name.length > 80) {
      throw new HttpsError(
        "invalid-argument",
        "Branch name must contain between 2 and 80 characters.",
      );
    }

    try {
      await withDatabase(databaseConfig(), (client) =>
        updateBranchNameForUser(client, {
          firebaseUid: uid,
          organizationId,
          branchId,
          name,
        }),
      );
      return {updated: true};
    } catch (error) {
      if (error instanceof AccessProfileDeniedError) {
        throw new HttpsError(
          "permission-denied",
          "The branch name cannot be changed by this account.",
        );
      }
      logger.error("Branch name update failed.", error);
      throw new HttpsError("internal", "Branch name update failed.");
    }
  },
);

function databaseConfig() {
  return {
    instanceConnectionName: databaseInstanceConnectionName.value(),
    database: databaseName.value(),
    user: databaseUser.value(),
  };
}

function requiredString(
  value: unknown,
  key: string,
): string {
  if (typeof value !== "object" || value === null) {
    throw new HttpsError("invalid-argument", "Request data is required.");
  }
  const candidate = (value as Record<string, unknown>)[key];
  if (typeof candidate !== "string" || candidate.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${key} is required.`);
  }
  return candidate.trim();
}
