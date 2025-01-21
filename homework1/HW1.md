Question 1 :
 
```console
foo@bar:~$ docker run -it --entrypoint bash python:3.12.8

```

Question 3 :

```sql
    select count(1) , 'Q1' as question from green_taxi_trips 
    where DATE(lpep_pickup_datetime)>= '2019-10-01' and DATE(lpep_pickup_datetime) < '2019-11-01'
    and DATE(lpep_dropoff_datetime)>= '2019-10-01' and DATE(lpep_dropoff_datetime) < '2019-11-01'
    and trip_distance <= 1
    union
    select count(1) , 'Q2' as question from green_taxi_trips 
    where DATE(lpep_pickup_datetime)>= '2019-10-01' and DATE(lpep_pickup_datetime) < '2019-11-01'
    and DATE(lpep_dropoff_datetime)>= '2019-10-01' and DATE(lpep_dropoff_datetime) < '2019-11-01'
    and trip_distance > 1 and trip_distance <=3
    union
    select count(1) , 'Q3' as question from green_taxi_trips 
    where DATE(lpep_pickup_datetime)>= '2019-10-01' and DATE(lpep_pickup_datetime) < '2019-11-01'
    and DATE(lpep_dropoff_datetime)>= '2019-10-01' and DATE(lpep_dropoff_datetime) < '2019-11-01'
    and trip_distance > 3 and trip_distance <=7
    union
    select count(1) , 'Q4' as question from green_taxi_trips 
    where DATE(lpep_pickup_datetime)>= '2019-10-01' and DATE(lpep_pickup_datetime) < '2019-11-01'
    and DATE(lpep_dropoff_datetime)>= '2019-10-01' and DATE(lpep_dropoff_datetime) < '2019-11-01'
    and trip_distance > 7 and trip_distance <=10
    union
    select count(1) , 'Q5' as question from green_taxi_trips 
    where DATE(lpep_pickup_datetime)>= '2019-10-01' and DATE(lpep_pickup_datetime) < '2019-11-01'
    and DATE(lpep_dropoff_datetime)>= '2019-10-01' and DATE(lpep_dropoff_datetime) < '2019-11-01'
    and trip_distance > 10
```


Question 4 :
```sql
    select 
        date(lpep_pickup_datetime) as d,
        max(trip_distance) as trip
    from green_taxi_trips
    group by d
    order by trip desc
```

Question 5 : 
```sql
SELECT z."Zone" , sum(g.total_amount) as amount FROM zones z join green_taxi_trips g
on z."LocationID" = g."PULocationID"
where date(g.lpep_pickup_datetime) ='2019-10-18'
group by z."Zone"
order by amount desc
```

Question 6 :
```sql
with joined as (SELECT z."Zone",g."PULocationID",g."DOLocationID" , max(g.tip_amount) as tip FROM zones z join green_taxi_trips g
on z."LocationID" = g."PULocationID"
where extract(year from g.lpep_pickup_datetime) ='2019' and extract(month from g.lpep_pickup_datetime) ='10'
and z."Zone"='East Harlem North'
group by 1,2,3
order by tip desc)

select joined.* , z."Zone" as DropOffZone
from joined  join zones z 
on z."LocationID" = joined."DOLocationID"
order by tip desc
```