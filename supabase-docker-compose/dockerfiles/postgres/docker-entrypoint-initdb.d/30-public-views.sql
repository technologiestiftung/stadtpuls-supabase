-- drop view public.extended_user_profiles;
create or replace view public.extended_user_profiles (
    id,
    username,
    display_name,
    created_at,
    link,
    description,
    sensors_count,
    records_count,
    categories,
    sensors
  ) as
select id,
  name::text,
  display_name::text,
  created_at,
  url::text,
  description::text,
  /* the next statement creates the sensors_count for each user */
  (
    select count(*)
    from public.sensors as ps
    where pup.id = ps.user_id
  ) as sensors_count,
  /* next we create the records_count */
  (
    select count(*)
    from "public".records as pr
      join public.sensors as ps on pr.sensor_id = ps.id
    group by ps.user_id
    having ps.user_id = pup.id
  ) as records_count,
  /*next we create the categories id array for the user */
  (
    select array (
        select distinct ps.category_id
        from "public".sensors as ps
        where pup.id = ps.user_id
      )
  ),
  /*next we create the sensors id array for the user */
  (
    select array (
        select ps.id
        from "public".sensors as ps
        where pup.id = ps.user_id
      )
  )
from public.user_profiles as pup
  /* we order the result by the users name case insensitive*/
order by lower(pup.name);