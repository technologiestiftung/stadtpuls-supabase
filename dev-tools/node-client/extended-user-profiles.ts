import { createClient } from "@supabase/supabase-js";
import { config } from "dotenv";
config();
// Create a single supabase client for interacting with your database
const supabase = createClient(
  "http://localhost:8000",
  process.env.SUPABASE_ANON_KEY
);

// This query string made the frontend fail
// since postgrest had an disambiguation error
// {
//   "message": "More than one relationship was found for sensors and user_id",
//   "hint": "By following the 'details' key, disambiguate the request by changing the url to /origin?select=relationship(*) or /origin?select=target!relationship(*)",
//   "details": [
//     {
//       "relationship": "sensors_user_id_fkey[user_id][id]",
//       "cardinality": "m2o",
//       "origin": "public.sensors",
//       "target": "public.user_profiles"
//     },
//     {
//       "relationship": "sensors_user_id_fkey[user_id][id]",
//       "cardinality": "m2o",
//       "origin": "public.sensors",
//       "target": "public.extended_user_profiles"
//     }
//   ]
// }
export const accountQueryString = `
  id,
  name,
  display_name,
  created_at,
  url,
  description,
  sensors (
    id,
    name,
    created_at,
    connection_type,
    external_id,
    description,
    location,
    latitude,
    longitude,
    altitude,
    category_id,
    icon_id,
    user_id,
    records (
      recorded_at,
      measurements
    ),
    user:user_profiles!user_id (
      name,
      display_name
    ),
    category:category_id (
      id,
      name
    )
  )
`;

async function main() {
  const { data, error } = await supabase
    .from("user_profiles")
    .select(accountQueryString); // ?
  console.log(error);
  console.log(data);
}

main().catch(console.error);
