import { definitions } from "@technologiestiftung/stadtpuls-supabase-definitions";
import fetch from "cross-fetch";
import {
  createRecords,
  createSensor,
  deleteUser,
  exec,
  signupUser,
  supabaseAnonKey,
  supabaseUrl,
} from "./utils";

describe(
  "things the rls should provide",
  () => {
    test(
      "should allow delete records as a user",
      async () => {
        const user = await signupUser();
        const sensor = await createSensor({
          user_id: user.id,
          name: "rls insert test",
        });
        const records = await createRecords(sensor.id, 10);

        const response = await fetch(
          `${supabaseUrl}/rest/v1/records?id=eq.${records[0].id}`,
          {
            method: "DELETE",
            headers: {
              apikey: supabaseAnonKey,
              "Content-Type": "application/json",
              Authorization: `Bearer ${user.token}`,
            },
          },
        );
        expect(response.status).toBe(204);
        expect(response.ok).toBe(true);
        await deleteUser(user.id);
      },
    );

    test(
      "should deny delete records as a user who does not own the record",
      async () => {
        const user = await signupUser();
        const user2 = await signupUser();
        const sensor = await createSensor({
          user_id: user.id,
          name: "rls insert test",
        });

        const records = await createRecords(sensor.id, 1);

        const q1result = await exec<definitions["records"]>(
          "select * from records",
          [],
        );
        const response = await fetch(
          `${supabaseUrl}/rest/v1/records?id=eq.${records[0].id}`,
          {
            method: "DELETE",
            headers: {
              apikey: supabaseAnonKey,
              "Content-Type": "application/json",
              Authorization: `Bearer ${user2.token}`,
            },
          },
        );
        expect(response.status).toBe(204);
        expect(response.ok).toBe(true);
        const q2result = await exec<definitions["records"]>(
          "select * from records",
          [],
        );
        // sneaky postgres does not tell you if the delete failed
        expect(q1result.rows.length).toBe(q2result.rows.length);
        await deleteUser(user.id);
        await deleteUser(user2.id);
      },
    );

    // eslint-disable-next-line jest/no-disabled-tests
    test.skip(
      "should allow to update records as a user who owns the record",
      async () => {
        // setup
        const user = await signupUser();
        const sensor = await createSensor({
          user_id: user.id,
          name: "rls insert test",
        });
        const records = await createRecords(sensor.id, 1);

        const response = await fetch(
          `${supabaseUrl}/rest/v1/records?id=eq.${records[0].id}`,
          {
            method: "PATCH",
            headers: {
              apikey: supabaseAnonKey,
              "Content-Type": "application/json",
              Authorization: `Bearer ${user.token}`,
            },
            body: JSON.stringify({
              measurements: [42, 23, 5],
              // recorded_at: new Date().toISOString(),
            }),
          },
        );
        console.log(await response.text());
        expect(response.status).toBe(200);

        expect(response.ok).toBe(true);
        expect(records[0].measurements).not.toEqual([42, 23, 5]);

        // tearDown
        await deleteUser(user.id);
      },
    );

    test(
      "should allow to insert records as a user who owns the sensor",
      async () => {
        // setup
        const user = await signupUser();
        const sensor = await createSensor({
          user_id: user.id,
          name: "rls insert test",
        });

        const response = await fetch(
          `${supabaseUrl}/rest/v1/records`,
          {
            method: "POST",
            headers: {
              apikey: supabaseAnonKey,
              "Content-Type": "application/json",
              Authorization: `Bearer ${user.token}`,
            },
            body: JSON.stringify({
              sensor_id: sensor.id,
              measurements: [1, 2, 3],
              recorded_at: new Date().toISOString(),
            }),
          },
        );
        expect(response.ok).toBe(true);
        // expect(sensors).toBeNull();

        // tearDown
        await deleteUser(user.id);
      },
    );
    test(
      "should fail to insert records as a user who does not owns the sensor",
      async () => {
        // setup
        const user = await signupUser();
        const sensor = await createSensor({
          user_id: user.id,
          name: "rls insert test",
        });
        const user2 = await signupUser();

        const response = await fetch(
          `${supabaseUrl}/rest/v1/records`,
          {
            method: "POST",
            headers: {
              apikey: supabaseAnonKey,
              "Content-Type": "application/json",
              Authorization: `Bearer ${user2.token}`,
            },
            body: JSON.stringify({
              sensor_id: sensor.id,
              measurements: [1, 2, 3],
              recorded_at: new Date().toISOString(),
            }),
          },
        );
        const json = await response.json();
        expect(response.ok).toBe(false);
        expect(json)
          .toMatchInlineSnapshot(
            `
      Object {
        "code": "42501",
        "details": null,
        "hint": null,
        "message": "new row violates row-level security policy for table \\"records\\"",
      }
    `,
          );
        // expect(sensors).toBeNull();

        // tearDown
        await deleteUser(user.id);
        await deleteUser(user2.id);
      },
    );
  },
);
