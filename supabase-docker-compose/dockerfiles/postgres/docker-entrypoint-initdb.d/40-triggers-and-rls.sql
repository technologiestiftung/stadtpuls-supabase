-- inserts a row into public.user_profiles when a user signs up
-- https://supabase.io/docs/ guides/auth#create-a-publicusers-table
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user();
create function public.handle_new_user() returns trigger as $$ begin
insert into public.user_profiles (id)
values (new.id);
return new;
end;
$$ language plpgsql security definer;
-- trigger the function every time a user is created
create trigger on_auth_user_created
after
insert on auth.users for each row execute procedure public.handle_new_user();
--
--
--
--
--
--
-- trigger for deleting userprofile when user is deleted from auth table
drop trigger if exists on_auth_user_deleted on auth.users;
drop function if exists public.handle_deleted_user();
create function public.handle_deleted_user() returns trigger as $$ begin
delete from public.user_profiles
where id = old.id;
return old;
end;
$$ language plpgsql security definer;
-- trigger the function every time a user is deleted
create trigger on_auth_user_deleted
after delete on auth.users for each row execute procedure public.handle_deleted_user();
--
--
--
--
--
/****************************************************************
 * trigger function for checking if external_id is set on new or
 * updated sensors.
 *****************************************************************/
drop trigger if exists on_sensors_external_id_check on public.sensors;
drop function if exists public.check_external_id();
create function public.check_external_id() returns trigger as $$ begin if new.connection_type = 'ttn' then if new.external_id is null then raise exception 'external_id cannot be null when connection type is %',
new.connection_type;
end if;
end if;
return new;
end;
$$ language plpgsql;
create trigger on_sensors_external_id_check before
insert
  or
update on public.sensors for each row execute function public.check_external_id ();
-- https://supabase.io/docs/guides/auth#disable-realtime-for-private-tables
/**
 * REALTIME SUBSCRIPTIONS
 * Only allow realtime listening on public tables.
 */
begin;
-- remove the realtime publication
drop publication if exists supabase_realtime;
-- re-create the publication but don't enable it for any tables
create publication supabase_realtime;
commit;
-- -- add a table to the publication
-- alter publication supabase_realtime add table records;
-- -- add other tables to the publication
-- alter publication supabase_realtime add table sensors;
--
--
--
--
--
--
-- enable row level security for all tables
alter table public.auth_tokens enable row level security;
alter table public.categories enable row level security;
alter table public.sensors enable row level security;
alter table public.records enable row level security;
alter table public.user_profiles enable row level security;
-- allow read access
-- start users
create policy "Allow read access on public users table" on public.user_profiles for
select using (auth.role() = 'anon');
create policy "Allow read access for authenticated on public users table" on public.user_profiles for
select using (auth.role() = 'authenticated');
create policy "Allow individual insert access" on public.user_profiles for
insert with check (auth.uid() = id);
create policy "Allow individual update access" on public.user_profiles for
update using (auth.uid() = id);
create policy "Allow individual delete access" on public.user_profiles for delete using (auth.uid() = id);
-- end users
-- start categories
create policy "Allow read access on public categories table" on public.categories for
select using (auth.role() = 'anon');
create policy "Allow read access on public categories table authorized" on public.categories for
select using (auth.role() = 'authenticated');
-- end categories
-- start sensors
create policy "Allow read access on public sensors table" on public.sensors for
select using (auth.role() = 'anon');
create policy "Allow read access for authenticated on public sensors table" on public.sensors for
select using (auth.role() = 'authenticated');
create policy "Allow individual insert access" on public.sensors for
insert with check (auth.uid() = "user_id");
create policy "Allow individual update access" on public.sensors for
update using (auth.uid() = "user_id");
create policy "Allow individual delete access" on public.sensors for delete using (auth.uid() = "user_id");
-- end sensors
--
-- start records
-- TODO: [STADTPULS-589] Make row level security work on insert update and delete records
-- Parameters need to be prefixed because the name clashes with `pm`'s columns
CREATE OR REPLACE FUNCTION public.owns_sensor (_user_id uuid, _sensor_id int4) RETURNS bool AS $$
SELECT EXISTS (
    SELECT 1
    FROM sensors
    WHERE sensors.id = _sensor_id
      AND sensors.user_id = _user_id
  );
$$ LANGUAGE sql SECURITY DEFINER;
--
CREATE OR REPLACE FUNCTION public.owns_record (_user_id uuid, _record_id int4) RETURNS bool AS $$
SELECT EXISTS (
    SELECT 1
    FROM sensors
    WHERE (
        SELECT user_id
        FROM sensors
        WHERE id = (
            SELECT sensor_id
            FROM records
            WHERE records.id = _record_id
          )
      ) = _user_id
  ) $$ LANGUAGE sql SECURITY DEFINER;
-- $$ LANGUAGE sql SECURITY DEFINER;
-- drop policy "Allow individual insert access" on public.records;
-- insert
create policy "Allow individual insert access" on public.records for
insert with check (public.owns_sensor (auth.uid (), "sensor_id"));
-- update
create policy "Allow individual update access" on public.records for
update using (public.owns_record (auth.uid (), "sensor_id")) with CHECK (public.owns_record (auth.uid (), "sensor_id"));
-- delete
create policy "Allow individual delete access" on public.records for delete using (public.owns_record(auth.uid(), "sensor_id"));
-- select
create policy "Allow read access on public records table" on public.records for
select using (auth.role() = 'anon');
create policy "Allow read access for authenticated on public records table" on public.records for
select using (auth.role() = 'authenticated');
-- end records/
--
--
--
--start auth_tokens/
-- create policy "Allow individual insert access" on public.authtokens for
-- insert with check (auth.uid() = "user_id");
create policy "Allow individual delete access" on public.auth_tokens for delete using (auth.uid() = "user_id");
-- end authtokens