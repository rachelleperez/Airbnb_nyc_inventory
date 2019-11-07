-- What do we have? All inventory in NYC. 
-- Is inventory distributed fairly across boroughs, (maybe neighbourhoods), room_type, relation to center of city (how can I define)?
-- POTENTIAL - Correlation with subway locations to most popular area. 
-- CONCLUSION - Make a hypothesis on inventory pattern of urban cities and test vs Melbourne.
-- CAN I REWORK PRICE ALGORITHM? 

SELECT * FROM airbnb_nyc;

ALTER TABLE airbnb_nyc
ALTER COLUMN name TYPE varchar (1000);

COPY airbnb_nyc FROM 'C:\Program Files\PostgreSQL\11\data\manual_upload\AB_NYC_2019 _import_csv.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM airbnb_nyc;

SELECT neighbourhood_group, COUNT(id) AS inventory_count, ROUND(AVG(price),2) AS average_price, COUNT(host_id) AS host_count
FROM airbnb_nyc
GROUP BY neighbourhood_group, 
ORDER BY COUNT(id) DESC;

*** OUTPUT ***

 neighbourhood_group | inventory_count | average_price | host_count
---------------------+-----------------+---------------+------------
 Manhattan           |           21661 |        196.88 |      21661
 Brooklyn            |           20104 |        124.38 |      20104
 Queens              |            5666 |         99.52 |       5666
 Bronx               |            1091 |         87.50 |       1091
 Staten Island       |             373 |        114.81 |        373
(5 rows)

-- NOTE: Staten Island has the 3rd highest average price, despite lowest inventory

SELECT room_type, COUNT(id) AS inventory_count, ROUND(AVG(price),2) AS average_price, COUNT(host_id) AS host_count
FROM airbnb_nyc
GROUP BY room_type
ORDER BY COUNT(id) DESC;

**** OUTPUT ***

    room_type    | inventory_count | average_price | host_count
-----------------+-----------------+---------------+------------
 Entire home/apt |           25409 |        211.79 |      25409
 Private room    |           22326 |         89.78 |      22326
 Shared room     |            1160 |         70.13 |       1160
(3 rows)

-- Can a commentary be made on pricing strategy? Shared room is least popular but priced similarly to Private room. Of course, people wouold go for Private.
-- If an Airbnb generates pricing, is it being logical in its suggestion?

SELECT neighbourhood_group, room_type, COUNT(id) AS inventory_count, ROUND(AVG(price),2) AS average_price, COUNT(host_id) AS host_count
FROM airbnb_nyc
GROUP BY neighbourhood_group, room_type
ORDER BY neighbourhood_group, room_type;

*** OUTPUT ***

 neighbourhood_group |    room_type    | inventory_count | average_price | host_count
---------------------+-----------------+-----------------+---------------+------------
 Bronx               | Entire home/apt |             379 |        127.51 |        379
 Bronx               | Private room    |             652 |         66.79 |        652
 Bronx               | Shared room     |              60 |         59.80 |         60
 Brooklyn            | Entire home/apt |            9559 |        178.33 |       9559
 Brooklyn            | Private room    |           10132 |         76.50 |      10132
 Brooklyn            | Shared room     |             413 |         50.53 |        413
 Manhattan           | Entire home/apt |           13199 |        249.24 |      13199
 Manhattan           | Private room    |            7982 |        116.78 |       7982
 Manhattan           | Shared room     |             480 |         88.98 |        480
 Queens              | Entire home/apt |            2096 |        147.05 |       2096
 Queens              | Private room    |            3372 |         71.76 |       3372
 Queens              | Shared room     |             198 |         69.02 |        198
 Staten Island       | Entire home/apt |             176 |        173.85 |        176
 Staten Island       | Private room    |             188 |         62.29 |        188
 Staten Island       | Shared room     |               9 |         57.44 |          9
(15 rows)


-- LOOK AT PRICING AND INVENTORY BEHAVIORS (by top hosts, by boroughs)

WITH neighbourhood_totals AS
(
	SELECT neighbourhood_group, COUNT(id) AS borough_total_inventory, ROUND(AVG(price),2) AS average_price, COUNT (DISTINCT host_id) AS host_count
	FROM airbnb_nyc
	GROUP BY neighbourhood_group 
	ORDER BY COUNT(id) DESC
),

neighbourhood_totals_by_room AS 
(
	SELECT neighbourhood_group, room_type, COUNT(id) AS borough_type_inventory, ROUND(AVG(price),2) AS average_price, COUNT (DISTINCT host_id) AS host_count
	FROM airbnb_nyc
	GROUP BY neighbourhood_group, room_type
	ORDER BY neighbourhood_group, room_type
)

SELECT * FROM neighbourhood_totals INNER JOIN neighbourhood_totals_by_room USING (neighbourhood_group);

**** OUTPUT ***

 neighbourhood_group | borough_total_inventory | average_price | host_count |    room_type    | borough_type_inventory | average_price | host_count
---------------------+-------------------------+---------------+------------+-----------------+------------------------+---------------+------------
 Bronx               |                    1091 |         87.50 |        789 | Entire home/apt |                    379 |        127.51 |        324
 Bronx               |                    1091 |         87.50 |        789 | Private room    |                    652 |         66.79 |        459
 Bronx               |                    1091 |         87.50 |        789 | Shared room     |                     60 |         59.80 |         43
 Brooklyn            |                   20104 |        124.38 |      15966 | Entire home/apt |                   9559 |        178.33 |       8649
 Brooklyn            |                   20104 |        124.38 |      15966 | Private room    |                  10132 |         76.50 |       7744
 Brooklyn            |                   20104 |        124.38 |      15966 | Shared room     |                    413 |         50.53 |        233
 Manhattan           |                   21661 |        196.88 |      16578 | Entire home/apt |                  13199 |        249.24 |      10571
 Manhattan           |                   21661 |        196.88 |      16578 | Private room    |                   7982 |        116.78 |       6230
 Manhattan           |                   21661 |        196.88 |      16578 | Shared room     |                    480 |         88.98 |        346
 Queens              |                    5666 |         99.52 |       3983 | Entire home/apt |                   2096 |        147.05 |       1849
 Queens              |                    5666 |         99.52 |       3983 | Private room    |                   3372 |         71.76 |       2203
 Queens              |                    5666 |         99.52 |       3983 | Shared room     |                    198 |         69.02 |        127
 Staten Island       |                     373 |        114.81 |        256 | Entire home/apt |                    176 |        173.85 |        153
 Staten Island       |                     373 |        114.81 |        256 | Private room    |                    188 |         62.29 |        113
 Staten Island       |                     373 |        114.81 |        256 | Shared room     |                      9 |         57.44 |          6
(15 rows)

-- Get % of borough inventory split between entire/private/shared. Similar distribution across borough? 
-- Get % of total hosts split by inventory type

-- NEXT: Room Types, Outdated inventory? Based on review year. 
-- NEXT: Review density map
-- Most popular  neighborhoods within each boroughs. Are the ones in outer boroughs, just the closest to Manhattan?
-- test - supply & demand
--- 


