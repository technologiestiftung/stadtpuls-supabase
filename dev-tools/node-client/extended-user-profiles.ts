import { createClient } from "@supabase/supabase-js";
import { config } from "dotenv";
config();
// Create a single supabase client for interacting with your database
const supabase = createClient(
  "http://localhost:8000",
  process.env.SUPABASE_ANON_KEY
);

async function main() {
  const { data, error } = await supabase
    .from("extended_user_profiles")
    .select("*"); // ?
  // console.log(error);
  // console.log(data);
}

main().catch(console.error);
