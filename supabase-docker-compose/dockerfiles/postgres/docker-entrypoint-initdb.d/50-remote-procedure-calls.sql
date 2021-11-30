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
CREATE OR REPLACE FUNCTION public.get_users_alphabetically()
  RETURNS SETOF public.user_profiles
  LANGUAGE plpgsql AS
$$
BEGIN
   RETURN QUERY
   SELECT * FROM public.user_profiles ORDER BY lower(name);
END;
$$;

-- get records count for individual user

-- to destroy it run
-- drop function public.get_user_records_count(selected_user_id uuid);
-- usage
-- select * from public.get_user_records_count ('46d0c09b-3af6-4452-9392-230672c85929');

CREATE OR REPLACE FUNCTION public.get_user_records_count(user_id uuid)
  RETURNS  bigint
  LANGUAGE plpgsql AS
$$
BEGIN
    RETURN (
    SELECT COUNT(*) FROM public.records as r
    WHERE r.sensor_id IN (
      SELECT id FROM public.sensors as s WHERE s.user_id = $1
    ));
END;
$$;