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

-- get users alphabetically (case-insensitively!)
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
CREATE OR REPLACE FUNCTION public.get_user_records_count(selected_user_id uuid)
  RETURNS integer
  LANGUAGE plpgsql AS
$$
BEGIN
    RETURN QUERY
    SELECT COUNT(*) FROM public.records
    WHERE sensor_id IN (
      SELECT id FROM public.sensors WHERE user_id = selected_user_id
    );
END;
$$;