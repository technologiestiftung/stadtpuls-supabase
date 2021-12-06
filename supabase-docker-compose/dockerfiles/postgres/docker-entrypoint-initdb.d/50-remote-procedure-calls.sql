--
--
--
--
--
-- function to allow a user to delete his account
-- this will nuke all his sensors and records
create or replace function public.delete_user() returns void LANGUAGE SQL SECURITY DEFINER AS $$
delete from public.user_profiles
where id = auth.uid();
delete from auth.users
where id = auth.uid();
$$;
-- -- get users alphabetically (case-insensitively!)
-- to remove it run
-- drop function public.get_users_alphabetically();
-- usage
-- select * from public.get_users_alphabetically();
CREATE OR REPLACE FUNCTION public.get_users_alphabetically() RETURNS SETOF public.user_profiles LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
SELECT *
FROM public.user_profiles
ORDER BY lower(name);
END;
$$;
-- get records count for individual user
-- to destroy it run
-- drop function public.get_user_records_count(selected_user_id uuid);
-- usage
-- select * from public.get_user_records_count ('46d0c09b-3af6-4452-9392-230672c85929');
CREATE OR REPLACE FUNCTION public.get_user_records_count(user_id uuid) RETURNS bigint LANGUAGE plpgsql AS $$ BEGIN RETURN (
    SELECT COUNT(*)
    FROM public.records as r
    WHERE r.sensor_id IN (
        SELECT id
        FROM public.sensors as s
        WHERE s.user_id = $1
      )
  );
END;
$$;
-- drop function public.get_extended_accounts();
-- usage
-- select
--   *
-- from
--   "public".get_extended_accounts ();
-- create or replace function public.get_extended_accounts ()
-- -- our function returns a full table
-- -- so we define the structure here
--   returns table (
--     id uuid, username text, display_name text, created_at timestamptz, link text, description text, sensors_count bigint, records_count bigint, categories integer [])
--   language plpgsql
--   as $$
--   -- since we have some output table variables (its columsn) names overlap with the columns of our select statements
--   -- we tell postgres to always use the columns
--   #variable_conflict use_column
-- begin
--   return QUERY (
--     /*
--      here we cast some of the values to not be forced to use the exact type like varchar(50)
--      instead we cast to text
--      */
--     select
--       id,
--       name::text,
--       display_name::text,
--       created_at,
--       url::text,
--       description::text,
--       /* the next statement creates the sensors_count for each user */
--       (
--         select
--           count(*)
--         from
--           public.sensors as ps
--         where
--           pup.id = ps.user_id) as sensors_count,
--         /* next we create the records_count */
--         (
--           select
--             count(*)
--           from
--             "public".records as pr
--             join public.sensors as ps on pr.sensor_id = ps.id
--           group by
--             ps.user_id
--           having
--             ps.user_id = pup.id) as records_count,
--             /*next we create the categories array for the user */
--           (
--             select
--               array ( select distinct
--                   ps.category_id
--                 from
--                   "public".sensors as ps
--                 where
--                   pup.id = ps.user_id))
--             from
--               public.user_profiles as pup
--               /* we order the result by the users name case insensitive*/
--             order by
--               lower(pup.name));
-- end;
-- $$;