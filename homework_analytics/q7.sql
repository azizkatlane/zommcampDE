--staging

{{
    config(
        materialized='view'
    )
}}

with tripdata as 
(
  select *
  from {{ source('staging','FHV_2019') }}
  where dispatching_base_num is not null 
)
select

    dispatching_base_num,
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropOff_datetime as timestamp) as dropOff_datetime,
    PUlocationID,
    DOlocationID,
    SR_Flag,
    Affiliated_base_number
    

from tripdata


--core

{{
    config(
        materialized='table'
    )
}}

with tripdata as (
    select * from {{ ref('stg_fhv_tripdata') }}
), 

dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)

select 

    tripdata.dispatching_base_num, 
    tripdata.pickup_datetime, 
    tripdata.dropOff_datetime,
    EXTRACT(YEAR FROM tripdata.pickup_datetime) AS year,
    EXTRACT(MONTH FROM tripdata.pickup_datetime) AS month,
    tripdata.PUlocationID, 
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    tripdata.DOlocationID, 
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,  
    tripdata.SR_Flag,
    tripdata.Affiliated_base_number

from tripdata
inner join dim_zones as pickup_zone
on tripdata.PUlocationID = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on tripdata.DOlocationID = dropoff_zone.locationid

--fct_fhv_monthly_zone_traveltime_p90.sql

{{
    config(
        materialized='table'
    )
}}

with trip_duration_calculated as (
    select
        *,
        timestamp_diff(dropOff_datetime, pickup_datetime, second) as trip_duration
    from {{ ref('dim_fhv_trips') }}
)

select 

    *,
    PERCENTILE_CONT(trip_duration, 0.90) 
    OVER (PARTITION BY year, month, PUlocationID, DOlocationID) AS trip_duration_p90


from trip_duration_calculated


--query

WITH ranked_data AS (
    SELECT 
        pickup_zone,
        dropoff_zone,
        trip_duration_p90,
        DENSE_RANK() OVER (PARTITION BY pickup_zone ORDER BY trip_duration_p90 DESC) AS rank

    FROM `zoomcamp-airflow-444903.dbt_mguerra.fct_fhv_monthly_zone_traveltime_p90`
    WHERE month = 11 AND year = 2019 AND pickup_zone IN ('Newark Airport', 'SoHo', 'Yorkville East')
)

SELECT DISTINCT 
    pickup_zone, 
    dropoff_zone, 
    trip_duration_p90
    
FROM ranked_data
WHERE rank = 2;