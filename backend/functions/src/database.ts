import {
  AuthTypes,
  Connector,
  IpAddressTypes,
} from "@google-cloud/cloud-sql-connector";
import {Pool, PoolClient} from "pg";

let pool: Pool | undefined;
let connector: Connector | undefined;
let activeConfigKey: string | undefined;

export type DatabaseConnectionConfig = {
  instanceConnectionName: string;
  database: string;
  user: string;
};

export async function withDatabase<T>(
  config: DatabaseConnectionConfig,
  operation: (client: PoolClient) => Promise<T>,
): Promise<T> {
  const configKey = [
    config.instanceConnectionName,
    config.database,
    config.user,
  ].join("|");

  if (pool === undefined || activeConfigKey !== configKey) {
    await pool?.end();
    connector?.close();
    connector = new Connector();
    const connectionOptions = await connector.getOptions({
      instanceConnectionName: config.instanceConnectionName,
      ipType: IpAddressTypes.PUBLIC,
      authType: AuthTypes.IAM,
    });
    pool = new Pool({
      ...connectionOptions,
      database: config.database,
      user: config.user,
      max: 5,
      idleTimeoutMillis: 30_000,
      connectionTimeoutMillis: 10_000,
    });
    activeConfigKey = configKey;
  }

  const client = await pool.connect();
  try {
    return await operation(client);
  } finally {
    client.release();
  }
}
