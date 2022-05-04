import debug from "debug";
import { isCI } from "ci-info";
import { Client, QueryResult } from "pg";
import { definitions } from "@technologiestiftung/stadtpuls-supabase-definitions";
import { createClient } from "@supabase/supabase-js";
import faker from "faker";
type UserProfile = definitions["user_profiles"];

import fetch from "node-fetch";
const debugQuery = debug.debug("query");

// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
export const databaseUrl = process.env.DATABASE_URL!;
export const supabaseUrl = process.env.SUPABASE_URL || "http://localhost:8000";

export const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || "123";
export const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || "123";

export const supabaseClient = createClient(supabaseUrl, supabaseServiceRoleKey);
export const supabaseAnonClient = createClient(supabaseUrl, supabaseAnonKey);

export async function truncateTables(client: Client) {
  await client.query("TRUNCATE auth.users restart identity cascade");
  await client.query("TRUNCATE public.user_profiles restart identity cascade");
}
interface Queries { sql: string, values: string[] }

export async function execQueries(queries: Queries[]): Promise<
  QueryResult<any>[]
> {
  const client = new Client({ connectionString: databaseUrl });
  try {
    await client.connect();
    const results: QueryResult<any>[] = [];
    for (const query of queries) {
      const res = await client.query(query.sql, query.values);
      results.push(res);
    }
    await truncateTables(client);
    await client.end();
    return results;
  } catch (error) {
    logError(error, queries);
    await truncateTables(client);
    await client.end();
    throw error;
  }
}
export async function execQuery(sql: string, values: string[]): Promise<unknown> {
  const client = new Client({ connectionString: databaseUrl });
  await client.connect();

  try {
    if (!client) {
      throw new Error("DB client not connected");
    }
    const res = await client.query(sql, values);
    await truncateTables(client);
    await client.end();
    return res;
  } catch (error) {
    logError(error, [{ sql, values }]);
    await truncateTables(client);
    await client.end();
    throw error;
  }
}
export async function exec<T>(sql: string, values: string[]): Promise<
  QueryResult<T>
> {
  const client = new Client({ connectionString: databaseUrl });
  await client.connect();

  try {
    if (!client) {
      throw new Error("DB client not connected");
    }
    const res = await client.query(sql, values);
    await client.end();
    return res;
  } catch (error) {
    logError(error, [{ sql, values }]);
    await client.end();
    throw error;
  }
}
function logError(error: unknown, queries: Queries[]): void {
  if (!isCI) {
    if (error instanceof Error) {
      for (const query of queries) {
        debugQuery(
          `DB error\n`,
          `query: ${query.sql}\n`,
          `values: ${query.values}\n`,
          // eslint-disable-next-line @typescript-eslint/ban-ts-comment
          //@ts-ignore
          `details: ${error.detail}`,
        );
      }

      return;
    }
  }
}

export async function signup(
  { email, password, url, anonKey }: {
    email: string,
    password: string,
    url: URL,
    anonKey: string,
  },
): Promise<{ token: string, id: string }> {
  const headers: HeadersInit = {
    "Content-Type": "application/json",
    apikey: anonKey,
  };
  const body = JSON.stringify({ email, password });
  const response = await fetch(url.href, { method: "POST", headers, body });
  if (!response.ok) {
    throw new Error(await response.text());
  }
  if (response.status === 200) {
    const json = (await response.json()) as {
      access_token: string,
      token_type: string,
      expires_in: number,
      refresh_token: string,
      user: {
        id: string,
        aud: string,
        role: string,
        email: string,
        confirmed_at: Date,
        last_sign_in_at: Date,
        app_metadata: { provider: string },
        user_metadata: null,
        created_at: Date,
        updated_at: Date,
      },
    };
    return { token: json.access_token, id: json.user.id };
  } else {
    const text = await response.text();
    throw new Error(text);
  }
}

export async function signupUser(name?: string, email?: string): Promise<
  { id: string, token: string, userProfile?: UserProfile }
> {
  const { id, token } = await signup({
    anonKey: supabaseAnonKey,
    email: email ? email : `${faker.internet.email()}`,
    password: faker.internet.password(),
    url: new URL(`${supabaseUrl}/auth/v1/signup`),
  });
  if (name) {
    const { data: userProfile, error } = await supabaseClient
      .from<UserProfile>("user_profiles")
      .update({ name })
      .eq("id", id)
      .single();

    if (error) {
      console.error(error);
      throw error;
    }
    if (userProfile === null) {
      throw new Error("User profile not found");
    }
    return { id, token, userProfile };
  }
  return { id, token };
}

export async function createSensor(
  { user_id, name, external_id }: {
    user_id: string,
    name?: string,
    external_id?: string,
  },
): Promise<definitions["sensors"]> {
  const { data: sensors, error: dError } = await supabaseClient.from<
    definitions["sensors"]
  >("sensors").insert([
    {
      name: name ? name : faker.random.words(2),
      user_id,
      external_id,
      connection_type: external_id ? "ttn" : "http",
      category_id: 1,
      latitude: parseFloat(faker.address.latitude()),
      longitude: parseFloat(faker.address.longitude()),
      altitude: faker.datatype.number({ min: 0, max: 100, precision: 0.1 }),
    },
  ]);
  if (!sensors) {
    throw dError;
  }
  return sensors[0];
}

export async function createRecords(sensorId: number, amount: number): Promise<
  definitions["records"][]
> {
  const { data: records, error: dError } = await supabaseClient.from<
    definitions["records"]
  >("records").insert(
    Array(amount).fill({
      sensor_id: sensorId,
      measurements: [1, 2, 3],
      recorded_at: new Date().toISOString(),
    }),
  );
  if (!records) {
    throw dError;
  }
  return records;
}

export async function deleteUser(id: string): Promise<void> {
  const client = new Client({ connectionString: databaseUrl });
  try {
    await client.connect();
    await client.query("DELETE FROM auth.users where id = $1", [id]);
    await client.end();
  } catch (error) {
    await client.end();
    throw error;
  }
}
