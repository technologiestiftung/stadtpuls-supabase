select sen.id,
  sen.name::text as name,
  sen.created_at,
  sen.description::text as description,
  /**/
  (
    select array [
      max(pr.measurements [1]
  ),
  min(pr.measurements [1]),
  avg(pr.measurements [1]) ]
from records as pr
where pr.sensor_id = sen.id
) as max_min_avg,
(
  select count(1)
  from records as pr
  where pr.sensor_id = sen.id
) as records_count,
(
  select pr.recorded_at
  from records as pr
  where pr.sensor_id = sen.id
  order by pr.recorded_at desc
  limit 1
) as last_seen
/*   (
 --     select json_agg(j)
 --     from (
 --         select recorded_at,
 --           measurements
 --         from records as pr
 --         where pr.sensor_id = sen.id
 --         order by pr.recorded_at desc
 --         limit 100
 --       ) as j
 --   )
 */
from sensors sen;
-- select sen.id,
--   sen.name::text as name,
--   sen.created_at,
--   sen.description::text as description,
--   (
--     select count(*)
--     from records as pr
--     where pr.sensor_id = sen.id
--   ) as records_count,
--   (
--     select max(pr.measurements [1])
--     from records as pr
--     where pr.sensor_id = sen.id
--   ),
--   (
--     select min(pr.measurements [1])
--     from records as pr
--     where pr.sensor_id = sen.id
--   ),
--   (
--     select avg(pr.measurements [1])
--     from records as pr
--     where pr.sensor_id = sen.id
--   ),
--   (
--     select pr.recorded_at
--     from records as pr
--     where pr.sensor_id = sen.id
--     order by pr.recorded_at desc
--     limit 1
--   ) as last_seen,
--   (
--     select json_agg(j)
--     from (
--         select recorded_at,
--           measurements
--         from records as pr
--         where pr.sensor_id = sen.id
--         order by pr.recorded_at desc
--         limit 1
--       ) as j
--   )
-- from sensors sen;