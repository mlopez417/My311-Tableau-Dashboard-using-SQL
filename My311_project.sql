/* 311 Service Request Project for CY 2022
-- Skills: SQL (cleaning, exploration), Tableau (visualization)

-- Data Sets:
My311LA Service Requests for 2022 from https://data.lacity.org/City-Infrastructure-Service-Requests/MyLA311-Service-Request-Data-2022/i5ke-k6by

Census Block 2020 (updated Mar 29,2023) from https://data.lacounty.gov/datasets/lacounty::census-blocks-2020/explore?location=34.161823%2C-118.370868%2C16.27&showTable=true
https://www.arcgis.com/sharing/rest/content/items/8a29319474fe44bb96152d0be8e778af/info/metadata/metadata.xml?format=default&output=html

LA County by zipcodes from https://www.laalmanac.com/communications/cm02_communities.php


-- Purpose:
Answer the following - 

1) What is the 311 service most commonly used for, and by which method are people using it? 
What are the most common types of 311 service requests in Los Angeles County in 2022?
How many requests are received through different request sources such as phone calls, mobile apps, and social media?

2) Where is the 311 service most used across LA county?
Which areas of Los Angeles County have the highest number of 311 service requests?
What are the most common types of requests in those areas?
How long does it take for 311 service requests to be resolved on average?

3) Are there trends over time regarding 311 service usage? By area? 
Are there any trends in the types of 311 service requests over time?
Are there any differences in the types of 311 service requests between different neighborhoods or districts?
How many requests are received and resolved on a daily, weekly, and monthly basis? [maybe]

4) Misc. : Do people prefer to call in anonymously or not care? 
What is the percentage of requests that are anonymous and what are the most common types of requests from anonymous sources?


-- Hypothesis: 
1) I expect 311 to be used for any non-emergency requests. Of those, I anticipate issues with city infrastructure might be the highest (knocked down trees, potholes, broken lights) etc. 
2) I expect people would mostly use 311 by phone. The purpose of the number was to make it easy to remember and easy to use. Though over time, specially with more tech-savvy generations, that might move more toward app based or web based interactions (social media). Such as how twitter is the 'new' call center for large companies
3) I anticipate there might be higher volume of requests in more densely populated areas. More people means more chances for people to report or need some kind of gov. assistance. Over time, I don't anticipate that to change much. 
4) I anticipate more people that use this service might not care about their anonimity. Unless someone is trying to report what might be considered a crime and not want to be apart of it, I think most requests won't have 'anonymous' set to true. 

*/

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------


---------------------------------

-- Data Importing

---------------------------------


/* Census_Blocks_2020 (LA) data set */
DROP TABLE IF EXISTS census_block_2020 CASCADE;
CREATE TABLE census_block_2020 (
OBJECTID text,
State text,
COUNTY text,
CT20 text,
BG20 text,
CB20 text,
CTCB20 text,
FEAT_TYPE text,
FIP20 text,
BGFIP20 text,
CITY text,
COMM text,
CITYCOMM text,
ZCTA20 text,
HD22 text,
HD_NAME text,
SPA22 text,
SPA_NAME text,
SUP21 text,
SUP_LABEL text,
POP20 text,
HOUSING20 text,
ShapeSTArea text,
ShapeSTLength text,
Shape text
);
COPY census_block_2020(OBJECTID,State,COUNTY,CT20,BG20,CB20,CTCB20,FEAT_TYPE,FIP20,BGFIP20,CITY,COMM,CITYCOMM,ZCTA20,HD22,HD_NAME,SPA22,SPA_NAME,SUP21,SUP_LABEL,POP20,HOUSING20,ShapeSTArea,ShapeSTLength,Shape) 
FROM 'G:\PostgresSQL\Projects\My311LA_project\Census_Blocks_2020.csv'
CSV HEADER;


/* all city + communities and their corresponding zipcodes (some with multiple) and includes those with PO Boxes */
DROP TABLE IF EXISTS zipcodes CASCADE;
CREATE TABLE zipcodes (
CITY_COM_IND int,
CITY_COMMUNITY text,
ZIPCODES text
);
COPY zipcodes(CITY_COM_IND,CITY_COMMUNITY,ZIPCODES) 
FROM 'G:\PostgresSQL\Projects\My311LA_project\city_comm_zipcodes.csv'
CSV HEADER;


/* 311 data set */
DROP TABLE IF EXISTS My311 CASCADE;
CREATE TABLE My311 (
SRNumber text,
CreatedDate text,
UpdatedDate text,
ActionTaken text,
Owner text,
RequestType text,
Status text,
RequestSource text,
CreatedByUserOrganization text,
MobileOS text,
Anonymous text,
AssignTo text,
ServiceDate text,
ClosedDate text,
AddressVerified text,
ApproximateAddress text,
Address text,
HouseNumber text,
Direction text,
StreetName text,
Suffix text,
ZipCode text,
Latitude text,
Longitude text,
Location text,
TBMPage text,
TBMColumn text,
TBMRow text,
APC text,
CD text,
CDMember text,
NC text,
NCName text,
PolicePrecinct text
);
COPY My311(SRNumber,CreatedDate,UpdatedDate,ActionTaken,Owner,RequestType,Status,RequestSource,CreatedByUserOrganization,MobileOS,Anonymous,AssignTo,ServiceDate,ClosedDate,AddressVerified,ApproximateAddress,Address,HouseNumber,Direction,StreetName,Suffix,ZipCode,Latitude,Longitude,Location,TBMPage,TBMColumn,TBMRow,APC,CD,CDMember,NC,NCName,PolicePrecinct) 
FROM 'G:\PostgresSQL\Projects\My311LA_project\MyLA311_Service_Request_Data_2022.csv'
CSV HEADER;



-----------------------------------------------------------------------------
-----------------------------------------------------------------------------


---------------------------------

-- Data Cleaning

---------------------------------

/* Changing data types */
ALTER TABLE census_block_2020
ALTER COLUMN pop20 TYPE INT
USING pop20::int;

ALTER TABLE census_block_2020
ALTER COLUMN shapestarea TYPE float
USING shapestarea::float;


ALTER TABLE my311
ALTER COLUMN latitude TYPE float
USING latitude::float;

ALTER TABLE my311
ALTER COLUMN longitude TYPE float
USING longitude::float;

ALTER TABLE my311
ALTER COLUMN tbmpage TYPE int
USING tbmpage::int;

ALTER TABLE my311
ALTER COLUMN cd TYPE int
USING cd::int;

ALTER TABLE my311
ALTER COLUMN nc TYPE int
USING nc::int;

ALTER TABLE my311
ALTER COLUMN zipcode TYPE text
USING zipcode::text;


/* Had to find the zipcode for 3 addresses where the original zipcode was 'VE' or 'VE,0'*/
UPDATE my311
SET zipcode = '90003' 
WHERE latitude = 33.9602048917 AND longitude = -118.256606272;

UPDATE my311
SET zipcode = '90001' 
WHERE latitude = 33.960095791 AND longitude = -118.258189185;

UPDATE my311
SET zipcode = '90001' 
WHERE latitude = 33.9602009086 AND longitude = -118.2576775;




/* Adding columns to split information into 'usable' values */
-- adding a 'created' date and time column, then 'spliting' createddate into each with cast
ALTER TABLE my311
ADD COLUMN created_date date;

ALTER TABLE my311
ADD COLUMN created_time time;

UPDATE my311
SET created_date = createddate::date, created_time = createddate::time;



-- adding a 'updated' date and time column, then 'spliting' updateddate into each with cast
ALTER TABLE my311
ADD COLUMN update_date date;

ALTER TABLE my311
ADD COLUMN update_time time;

UPDATE my311
SET update_date = updateddate::date, update_time = updateddate::time;



-- adding a 'serviced' date and time column, then 'spliting' servicedate into each with cast
ALTER TABLE my311
ADD COLUMN service_date date;

ALTER TABLE my311
ADD COLUMN service_time time;

UPDATE my311
SET service_date = servicedate::date, service_time = servicedate::time;


-- adding a 'closed' date and time column, then 'spliting' closeddate into each with cast
ALTER TABLE my311
ADD COLUMN closed_date date;

ALTER TABLE my311
ADD COLUMN closed_time time;

UPDATE my311
SET closed_date = closeddate::date, closed_time = closeddate::time;


SELECT created_date,created_time,update_date,update_time,service_date,service_time,closed_date,closed_time FROM my311;

-- Used this to remove 50+ addresses that had zipcode = 0 by using google maps and the latitude/longitude
-- SELECT address, latitude, longitude FROM my311
-- WHERE zipcode::int = 0 ;

-- UPDATE my311
-- SET zipcode = '91201'
-- WHERE latitude = 34.155298012 AND longitude = -118.310904979;

-- SELECT * FROM zipcodes;

--INSERT INTO zipcodes(city_com_ind,city_community,zipcodes) VALUES (143,'Glendale', '91201');

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------


---------------------------------

-- Data Exploratory

---------------------------------


/* List of main table queries for faster reference.*/ 
SELECT * FROM zipcodes; 
SELECT * FROM census_block_2020;
SELECT * FROM My311;


/*This shows me cities and communities(neighborhoods) with total population, total area by meters, and population density by square miles, 
includes unincorporated areas. */
DROP VIEW IF EXISTS census_pop_size_density CASCADE;
CREATE OR REPLACE VIEW census_pop_size_density AS (
SELECT city, COMM, citycomm, SUM(pop20), round(SUM(ShapeSTArea)::bigint*3.86102e-7,2) AS Area_from_sqmeters_to_sqmiles, 
	   Round(SUM(pop20)/(SUM(ShapeSTArea)::bigint*3.86102e-7),2) AS pop_density FROM census_block_2020
WHERE city is not null
group by city, citycomm, COMM
ORDER BY 6 DESC); -- population 10M across ALL LA county, ShapeSTArea is in SQ METERS! Had it converted in sq miles. 

SELECT * FROM census_pop_size_density;

-- same as above but adds a zipcode to it
DROP VIEW IF EXISTS census_pop_size_density_zipcode CASCADE;
CREATE OR REPLACE VIEW census_pop_size_density_zipcode AS (
SELECT city, COMM, citycomm, zcta20, SUM(pop20), round(SUM(ShapeSTArea)::bigint*3.86102e-7,2) AS Area_from_sqmeters_to_sqmiles, Round(SUM(pop20)/(SUM(ShapeSTArea)::bigint*3.86102e-7),2) AS pop_density FROM census_block_2020
WHERE city is not null
group by city, citycomm, COMM, zcta20
ORDER BY 5 DESC);


/* Population Density by city (incorporate only) using square miles. Ordered by density. 
US population density avg is 94 using: https://www.worldometers.info/world-population/us-population/#:~:text=The%20population%20density%20in%20the,94%20people%20per%20mi2).&text=The%20median%20age%20in%20the%20United%20States%20is%2038.3%20years.*/
SELECT city, SUM(pop20), round(SUM(ShapeSTArea)::bigint*3.86102e-7,2) AS Area_from_sqmeters_to_sqmiles, Round(SUM(pop20)/(SUM(ShapeSTArea)::bigint*3.86102e-7),2) AS pop_density,
Round(((Round(SUM(pop20)/(SUM(ShapeSTArea)::bigint*3.86102e-7),2))/94)*100,2) AS popdensity_vs_USdensity_perce FROM census_block_2020
WHERE city is not null AND city NOT IN ('Unincorporated')
group by city
ORDER BY 5 DESC, 2 DESC;

/* For ALL of LA county (incorporated and unincorporated). 10M ppl, across an area of 51K sq miles, an average population density of 196 people per sq mile, and when compared to the US - is over 208% above the national average. */
SELECT SUM(pop20), round(SUM(ShapeSTArea)::bigint*3.86102e-7,2) AS Area_from_sqmeters_to_sqmiles, Round(SUM(pop20)/(SUM(ShapeSTArea)::bigint*3.86102e-7),2) AS pop_density,
Round(((Round(SUM(pop20)/(SUM(ShapeSTArea)::bigint*3.86102e-7),2))/94)*100,2) AS popdensity_vs_USdensity_perce FROM census_block_2020
ORDER BY 4 DESC, 1 DESC;

/* A test to convert meters squared to miles squared*/
SELECT SUM(ShapeSTArea)*3.86102e-7 AS meter_to_mileSQ FROM census_block_2020;


/* Types of organizations that create 311 requests: */
-- BOE : Bureau of Engineering, BSL: Bureau of Street Lighting, BSS: Bureau of Street Services
-- Council's Office, ITA: Info. Tech Agency, LAAS: LA Animal Services, LASAN: LA Sanitation, 
-- LASAN Franchise: LA Sanitation but for business (think recyclers), OCB : office of community beautification, 
-- Proactive Insert: ??, Self Service : web/app/portal, Self Service_SAN : web/app/portal
SELECT DISTINCT createdbyuserorganization FROM my311;

-- Working on getting the month from the created_date column.
SELECT created_date, EXTRACT(MONTH FROM created_date) FROM my311;

/* Requests Made, closed, or left open by Month. Ordered by month, shows sum of requests open/closed,remaining by day. */
-- Note: consider a 1 level drill down in Tableau (Month -> made,closed,not closed)
-- Turned from CTE to view. 
DROP VIEW IF EXISTS my311_requests_by_month CASCADE;
CREATE OR REPLACE VIEW my311_requests_by_month AS(
	SELECT *,
	CASE
		WHEN EXTRACT(MONTH FROM created_date) = '01' THEN 'January'
		WHEN EXTRACT(MONTH FROM created_date) = '02' THEN 'February'
		WHEN EXTRACT(MONTH FROM created_date) = '03' THEN 'March'
		WHEN EXTRACT(MONTH FROM created_date) = '04' THEN 'April'
		WHEN EXTRACT(MONTH FROM created_date) = '05' THEN 'May'
		WHEN EXTRACT(MONTH FROM created_date) = '06' THEN 'June'
		WHEN EXTRACT(MONTH FROM created_date) = '07' THEN 'July'
		WHEN EXTRACT(MONTH FROM created_date) = '08' THEN 'August'
		WHEN EXTRACT(MONTH FROM created_date) = '09' THEN 'September'
		WHEN EXTRACT(MONTH FROM created_date) = '10' THEN 'October'
		WHEN EXTRACT(MONTH FROM created_date) = '11' THEN 'November'
		WHEN EXTRACT(MONTH FROM created_date) = '12' THEN 'December'
	END AS created_month,
	CASE
		WHEN EXTRACT(MONTH FROM closed_date) = '01' THEN 'January'
		WHEN EXTRACT(MONTH FROM closed_date) = '02' THEN 'February'
		WHEN EXTRACT(MONTH FROM closed_date) = '03' THEN 'March'
		WHEN EXTRACT(MONTH FROM closed_date) = '04' THEN 'April'
		WHEN EXTRACT(MONTH FROM closed_date) = '05' THEN 'May'
		WHEN EXTRACT(MONTH FROM closed_date) = '06' THEN 'June'
		WHEN EXTRACT(MONTH FROM closed_date) = '07' THEN 'July'
		WHEN EXTRACT(MONTH FROM closed_date) = '08' THEN 'August'
		WHEN EXTRACT(MONTH FROM closed_date) = '09' THEN 'September'
		WHEN EXTRACT(MONTH FROM closed_date) = '10' THEN 'October'
		WHEN EXTRACT(MONTH FROM closed_date) = '11' THEN 'November'
		WHEN EXTRACT(MONTH FROM closed_date) = '12' THEN 'December'
	END AS closed_month
	FROM my311
);
SELECT created_month, created_date, COUNT(created_month) AS Request_Made, COUNT(closed_month) AS Request_Closed, COUNT(created_month)-COUNT(closed_month) AS Requests_NOT_closed  FROM my311_requests_by_month
GROUP BY created_month, created_date
ORDER BY 2;

/* 87% of requests made in FY22 were not anonymous. i.e. did not matter. 12% were anonymous. */
SELECT DISTINCT anonymous, count(anonymous) OVER (partition by anonymous) AS Count_by_Boolean, count(anonymous) OVER () AS Count_total, ROUND((count(anonymous)OVER (partition by anonymous)::decimal/count(anonymous) OVER ()::decimal)*100,2) AS percentage FROM My311
ORDER BY 4 DESC;

/* 75% of requests from Self-Service 'orgs' as in, individual citizen, not from an actual organization did not care to be anonymous. While 24% did. 
From the data source -  Shows which department the service request creator is from. Self-Service = MyLA311 portal/app. */
SELECT DISTINCT anonymous, count(anonymous) OVER (partition by anonymous) AS Count_by_Boolean, count(anonymous) OVER () AS Count_total, ROUND((count(anonymous)OVER (partition by anonymous)::decimal/count(anonymous) OVER ()::decimal)*100,2) AS percentage FROM My311
WHERE createdbyuserorganization = 'Self Service'
ORDER BY 4 DESC;

/* Out of ALL requests in FY22, 46% were over Bulky Items. Followed at 24% by Graffiti Removal. 
The least used services were Feedback at .05% follwed by Reporting Water Waste at .33%*/
SELECT DISTINCT requesttype, count(requesttype) OVER (PARTITION BY requesttype) AS request_type_count, ROUND((count(requesttype)OVER (partition by requesttype)::decimal/count(requesttype) OVER ()::decimal)*100,2) AS percentage  FROM my311
ORDER BY 2 DESC;

/* There are 12 distinct service types available: Bulky Items, Dead Animal Removal, Electronic Waste, Feedback, Graffiti Removal,
Homeless Encampment, Illegal Dumping Pickup, Metal/Household Applicances, Multiple Streetlight issues, Other, Report Water Waste,
Single Streetlight Issue. */
SELECT DISTINCT requesttype FROM my311;

/* Views ALL requests types by month, # of created requests compared to total count by type in the year. Value in percentage.
Ordered by month to keep uniformity. Adding a 'where' clause can let me look at one specific request type. */
DROP VIEW IF EXISTS request_type_month_percentage;
CREATE OR REPLACE VIEW request_type_month_percentage as (
SELECT DISTINCT requesttype,
	CASE
		WHEN EXTRACT(MONTH FROM created_date) = '01' THEN '01 - January'
		WHEN EXTRACT(MONTH FROM created_date) = '02' THEN '02 - February'
		WHEN EXTRACT(MONTH FROM created_date) = '03' THEN '03 - March'
		WHEN EXTRACT(MONTH FROM created_date) = '04' THEN '04 - April'
		WHEN EXTRACT(MONTH FROM created_date) = '05' THEN '05 - May'
		WHEN EXTRACT(MONTH FROM created_date) = '06' THEN '06 - June'
		WHEN EXTRACT(MONTH FROM created_date) = '07' THEN '07 - July'
		WHEN EXTRACT(MONTH FROM created_date) = '08' THEN '08 - August'
		WHEN EXTRACT(MONTH FROM created_date) = '09' THEN '09 - September'
		WHEN EXTRACT(MONTH FROM created_date) = '10' THEN '10 - October'
		WHEN EXTRACT(MONTH FROM created_date) = '11' THEN '11 - November'
		WHEN EXTRACT(MONTH FROM created_date) = '12' THEN '12 - December'
	END AS created_month,
	COUNT(requesttype) OVER (PARTITION BY requesttype, EXTRACT(MONTH FROM created_date)) AS total_count, COUNT(requesttype) OVER (partition by requesttype) AS total_request_CY22, 
	ROUND((COUNT(requesttype) OVER (PARTITION BY requesttype, EXTRACT(MONTH FROM created_date))::decimal/COUNT(requesttype) OVER (partition by requesttype)::decimal)*100,2) as percentage_by_month  FROM my311
ORDER BY 2
);
SELECT * FROM request_type_month_percentage;

-- an example of the view above but narrowed to a request type. 
SELECT * FROM request_type_month_percentage
WHERE requesttype = 'Bulky Items';

/* There are 14 distinct methods by which the city received 311: Chat, City Attorney, Council's Office, Driver Self Report, Email, 
Mobile App, Queue Initiated Customer Call, Radio, Self Service, Social, Voicemail, Walk-in, Web Form. 
From site - "The source that the service request was received. Self Service = MyLA311 web portal, Web-Form = internal/external online forms, Driver Self Report = By work crews for work done in field then entered into system." */
SELECT DISTINCT requestsource FROM my311;

/* This view allowed me to consolidate some date before joining it 'request_type_month_percentage' which would give me # of requests 
by month along with where these requests were received using requestsource. Outcome view: reqtype_reqsrc */
DROP VIEW IF EXISTS requesttype_with_requestsource CASCADE;
CREATE OR REPLACE VIEW requesttype_with_requestsource AS (
SELECT DISTINCT requesttype, requestsource,
	CASE
		WHEN EXTRACT(MONTH FROM created_date) = '01' THEN '01 - January'
		WHEN EXTRACT(MONTH FROM created_date) = '02' THEN '02 - February'
		WHEN EXTRACT(MONTH FROM created_date) = '03' THEN '03 - March'
		WHEN EXTRACT(MONTH FROM created_date) = '04' THEN '04 - April'
		WHEN EXTRACT(MONTH FROM created_date) = '05' THEN '05 - May'
		WHEN EXTRACT(MONTH FROM created_date) = '06' THEN '06 - June'
		WHEN EXTRACT(MONTH FROM created_date) = '07' THEN '07 - July'
		WHEN EXTRACT(MONTH FROM created_date) = '08' THEN '08 - August'
		WHEN EXTRACT(MONTH FROM created_date) = '09' THEN '09 - September'
		WHEN EXTRACT(MONTH FROM created_date) = '10' THEN '10 - October'
		WHEN EXTRACT(MONTH FROM created_date) = '11' THEN '11 - November'
		WHEN EXTRACT(MONTH FROM created_date) = '12' THEN '12 - December'
	END AS created_month, 
	created_date, COUNT(requestsource) AS counted_requests FROM my311
GROUP BY requesttype, requestsource, created_date
ORDER BY 3, 2);

DROP VIEW IF EXISTS requesttype_with_requestsource_v2 CASCADE;
CREATE OR REPLACE VIEW requesttype_with_requestsource_v2 AS (
SELECT DISTINCT requesttype, created_month, requestsource, SUM(counted_requests) AS Received_requests_by_source FROM requesttype_with_requestsource
GROUP BY requesttype, requestsource, created_month);

SELECT * FROM requesttype_with_requestsource_v2;

/* Query organizes requests by month, type, total count, which communication method the request came from, and the number of requests per source.
When ordered by total count and number of requests per source, Bulky Items is the most used service with 311. Followed by Graffitti Removal */
DROP VIEW IF EXISTS reqtype_reqsrc CASCADE;
CREATE OR REPLACE VIEW reqtype_reqsrc AS (
SELECT DISTINCT req.created_month, req.requesttype, req.total_count, src.requestsource, 
	            SUM(src.Received_requests_by_source) AS request_sum FROM request_type_month_percentage req
JOIN requesttype_with_requestsource_v2 src ON req.requesttype = src.requesttype AND req.created_month = src.created_month
GROUP BY req.requesttype, req.created_month, req.total_count, src.requestsource
ORDER BY 1, 4);

SELECT * FROM reqtype_reqsrc
ORDER BY 3 DESC,5 DESC;

-- Gives a view for the year on which requestsource requests were collected on the most (where it was received).
SELECT DISTINCT requestsource, SUM(request_SUM) FROM reqtype_reqsrc
GROUP BY requestsource
ORDER BY 2 DESC;

-- This shows total count of requests by request type each month, along with the different requestsources and count of requestsrcs. 
SELECT * FROM reqtype_reqsrc
WHERE requesttype = 'Bulky Items';

/* 40.4429% of ALL requests in CY22 came from a Self-Service means (likely a regular citizen). Followed immediately by ~35% from LA 
Sanitation. 59.55% of the requests are done by an organized group IN the city, not necessarily an individual citizen. */
DROP VIEW IF EXISTS created_by CASCADE;
CREATE OR REPLACE VIEW created_by AS (
WITH CTE_created_By AS (
SELECT createdbyuserorganization, COUNT(createdbyuserorganization) AS total_count FROM my311
GROUP BY createdbyuserorganization)
SELECT createdbyuserorganization, total_count, SUM(total_count) OVER (), ROUND((total_count::decimal/SUM(total_count) OVER ()::decimal)*100,4)FROM CTE_created_By
GROUP BY createdbyuserorganization,total_count
ORDER BY 2 DESC);

SELECT * FROM created_by;

/* Of ALL requests in the year, those that came from self-service by servicetype. Added created_month so show requests by month.*/
DROP VIEW IF EXISTS self_service_by_reqtype CASCADE;
CREATE OR REPLACE VIEW self_service_by_reqtype AS (
SELECT 	
	CASE
		WHEN EXTRACT(MONTH FROM orign.created_date) = '01' THEN '01 - January'
		WHEN EXTRACT(MONTH FROM orign.created_date) = '02' THEN '02 - February'
		WHEN EXTRACT(MONTH FROM orign.created_date) = '03' THEN '03 - March'
		WHEN EXTRACT(MONTH FROM orign.created_date) = '04' THEN '04 - April'
		WHEN EXTRACT(MONTH FROM orign.created_date) = '05' THEN '05 - May'
		WHEN EXTRACT(MONTH FROM orign.created_date) = '06' THEN '06 - June'
		WHEN EXTRACT(MONTH FROM orign.created_date) = '07' THEN '07 - July'
		WHEN EXTRACT(MONTH FROM orign.created_date) = '08' THEN '08 - August'
		WHEN EXTRACT(MONTH FROM orign.created_date) = '09' THEN '09 - September'
		WHEN EXTRACT(MONTH FROM orign.created_date) = '10' THEN '10 - October'
		WHEN EXTRACT(MONTH FROM orign.created_date) = '11' THEN '11 - November'
		WHEN EXTRACT(MONTH FROM orign.created_date) = '12' THEN '12 - December'
	END AS created_month, 
	org.createdbyuserorganization, orign.requesttype, COUNT(orign.requesttype) as reqtype_count FROM created_by org
JOIN my311 orign ON org.createdbyuserorganization = orign.createdbyuserorganization
WHERE org.createdbyuserorganization = 'Self Service' -- AND (orign.created_date IS NOT NULL AND orign.closed_date IS NOT NULL)
GROUP BY org.createdbyuserorganization, orign.requesttype, created_date
ORDER BY reqtype_count DESC);

SELECT DISTINCT * FROM self_service_by_reqtype;

SELECT * FROM my311; -- ncname (neighborhood council name)
SELECT * FROM census_block_2020;
SELECT * FROM zipcodes;

-- A zipcode per citycommunity (not by city a.k.a. incorporated city)
SELECT DISTINCT citycomm, zcta20 FROM census_block_2020
GROUP BY citycomm, zcta20
ORDER BY 2 DESC;

SELECT COUNT(zcta20) FROM census_block_2020; -- 90.9K zipcodes in ALL of LA county



/* This shows which neighborhoods/cities have made the most 311 requests. Los Angeles having so many neighborhoods
would be expected to be high. 55.72% came from Los Angeles proper, while next highest neighborhood was at 4.64%
which was North Hollywood (fyi, NH has like 5 or 6 zipcodes) */
DROP VIEW IF EXISTS neighborhood_requests CASCADE;
CREATE OR REPLACE VIEW neighborhood_requests AS (
WITH CTE_neighborhood_requests AS(
SELECT TRIM(zip.city_community) AS community, count(srnumber) AS request_total FROM my311 req
FULL JOIN zipcodes zip ON req.zipcode = zip.zipcodes
GROUP BY zip.city_community
ORDER BY 2 DESC)
SELECT DISTINCT community, request_total, ROUND((SUM(request_total)::decimal/SUM(request_total) OVER ()::decimal)*100,4) as percentage FROM CTE_neighborhood_requests
GROUP BY community,request_total
ORDER BY 2 DESC); -- 1,327,870 my311 requests

SELECT * FROM neighborhood_requests;


-- same view as above but drilled down by neighborhood + zipcode
SELECT TRIM(zip.city_community) AS community, req.zipcode, count(srnumber) FROM my311 req
FULL JOIN zipcodes zip ON req.zipcode = zip.zipcodes
GROUP BY zip.city_community, req.zipcode
ORDER BY 3 DESC; -- 1,327,870 my311 requests

/* This shows which neighborhoods/cities have made the most 311 requests and the request type. Ordered by most requests in that neighborhood.*/
DROP VIEW IF EXISTS requests_by_neighborhood_requesttype CASCADE;
CREATE OR REPLACE VIEW requests_by_neighborhood_requesttype AS (
WITH CTE_neighborhood_req2 AS(
SELECT TRIM(zip.city_community) AS community, req.requesttype, count(srnumber) AS request_total FROM my311 req
FULL JOIN zipcodes zip ON req.zipcode = zip.zipcodes
GROUP BY zip.city_community, req.requesttype
ORDER BY 3 DESC)
SELECT *, ROUND((SUM(request_total)::decimal/SUM(request_total) OVER ()::decimal)*100,4) as percentage FROM CTE_neighborhood_req2
GROUP BY community,request_total, requesttype
ORDER BY 3 DESC); 

SELECT * FROM requests_by_neighborhood_requesttype;

-- SELECT * FROM my311 req
-- FULL JOIN zipcodes zip ON req.zipcode = zip.zipcodes
-- WHERE req.zipcode IS NULL;


SELECT * FROM my311 
WHERE (created_date IS NOT NULL) AND (closed_date IS NOT NULL); --1,305,700 requests opened and closed up to 3/2023.


/* This groups the data from my311 along with zipcode and how long each request got closed, along with it's avergae
for the year 2022. This looks specifically at cases opened and closed within 2022. */
DROP VIEW IF EXISTS average_ticket_closed CASCADE;
CREATE OR REPLACE VIEW average_ticket_closed AS (
SELECT srnumber, requesttype, requestsource, zipcode, 
	CASE
		WHEN EXTRACT(MONTH FROM created_date) = '01' THEN '01 - January'
		WHEN EXTRACT(MONTH FROM created_date) = '02' THEN '02 - February'
		WHEN EXTRACT(MONTH FROM created_date) = '03' THEN '03 - March'
		WHEN EXTRACT(MONTH FROM created_date) = '04' THEN '04 - April'
		WHEN EXTRACT(MONTH FROM created_date) = '05' THEN '05 - May'
		WHEN EXTRACT(MONTH FROM created_date) = '06' THEN '06 - June'
		WHEN EXTRACT(MONTH FROM created_date) = '07' THEN '07 - July'
		WHEN EXTRACT(MONTH FROM created_date) = '08' THEN '08 - August'
		WHEN EXTRACT(MONTH FROM created_date) = '09' THEN '09 - September'
		WHEN EXTRACT(MONTH FROM created_date) = '10' THEN '10 - October'
		WHEN EXTRACT(MONTH FROM created_date) = '11' THEN '11 - November'
		WHEN EXTRACT(MONTH FROM created_date) = '12' THEN '12 - December'
	END AS created_month, created_date, 
		CASE
		WHEN EXTRACT(MONTH FROM closed_date) = '01' THEN '01 - January'
		WHEN EXTRACT(MONTH FROM closed_date) = '02' THEN '02 - February'
		WHEN EXTRACT(MONTH FROM closed_date) = '03' THEN '03 - March'
		WHEN EXTRACT(MONTH FROM closed_date) = '04' THEN '04 - April'
		WHEN EXTRACT(MONTH FROM closed_date) = '05' THEN '05 - May'
		WHEN EXTRACT(MONTH FROM closed_date) = '06' THEN '06 - June'
		WHEN EXTRACT(MONTH FROM closed_date) = '07' THEN '07 - July'
		WHEN EXTRACT(MONTH FROM closed_date) = '08' THEN '08 - August'
		WHEN EXTRACT(MONTH FROM closed_date) = '09' THEN '09 - September'
		WHEN EXTRACT(MONTH FROM closed_date) = '10' THEN '10 - October'
		WHEN EXTRACT(MONTH FROM closed_date) = '11' THEN '11 - November'
		WHEN EXTRACT(MONTH FROM closed_date) = '12' THEN '12 - December'
	END AS closed_month, closed_date, closed_date - created_date AS duretion, ROUND((AVG(closed_date - created_date) OVER ()),2) as average FROM my311
WHERE (created_date IS NOT NULL AND closed_date IS NOT NULL) AND closed_date < '2022-12-31'
ORDER BY 6,9 DESC); --1,286,087 requests opened and closed IN the year 2022, ave resolution 5.49 days

-----------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS census_popdensity CASCADE;
CREATE OR REPLACE VIEW census_popdensity AS(
SELECT city, COMM, citycomm, zcta20, SUM(pop20) AS population, round(SUM(ShapeSTArea)::bigint*3.86102e-7,2) AS Area_from_sqmeters_to_sqmiles, Round(SUM(pop20)/(SUM(ShapeSTArea)::bigint*3.86102e-7),2) AS pop_density FROM census_block_2020
WHERE city is not null
group by city, citycomm, COMM, zcta20
ORDER BY 5 DESC);

/*Query shows the use of 311 services (count) per neighborhood and their associated population density created earlier.
*/
DROP VIEW IF EXISTS my311_with_popdensity CASCADE;
CREATE OR REPLACE VIEW my311_with_popdensity AS(
SELECT DISTINCT census.citycomm AS neighborhood, orign.zipcode AS zipcode, count(orign.srnumber), census.population,  census.pop_density 
	FROM census_popdensity census
JOIN my311 orign ON census.zcta20 = orign.zipcode
GROUP BY orign.zipcode, census.pop_density, census.citycomm, census.population
ORDER BY 3 DESC, 4 DESC, 5 DESC);

SELECT * FROM my311_with_popdensity;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------


---------------------------------

-- Exporting modified tables to CSV
-- To be used in Tableau

---------------------------------


COPY my311 to 'G:\PostgresSQL\Projects\My311LA_project\my311_updated.csv'
CSV HEADER;

COPY census_block_2020 to 'G:\PostgresSQL\Projects\My311LA_project\census_data_cleaned.csv'
CSV HEADER;

COPY zipcodes to 'G:\PostgresSQL\Projects\My311LA_project\city_zipcode_CHATGPT.csv'
CSV HEADER;

----------------------------------

COPY (SELECT * FROM census_pop_size_density) to 'G:\PostgresSQL\Projects\My311LA_project\Views\census_population_sqmile_popdensity_view1.csv'
CSV HEADER;

COPY (SELECT * FROM census_pop_size_density_zipcode) to 'G:\PostgresSQL\Projects\My311LA_project\Views\census_population_sqmile_popdensity_zip_view2.csv'
CSV HEADER;

COPY (SELECT * FROM census_popdensity) to 'G:\PostgresSQL\Projects\My311LA_project\Views\census_popdensity_view3.csv'
CSV HEADER;

COPY (SELECT * FROM created_by) to 'G:\PostgresSQL\Projects\My311LA_project\Views\created_by_view4.csv'
CSV HEADER;

COPY (SELECT * FROM my311_requests_by_month) to 'G:\PostgresSQL\Projects\My311LA_project\Views\my311_requests_by_month_view5.csv'
CSV HEADER;

COPY (SELECT * FROM my311_with_popdensity) to 'G:\PostgresSQL\Projects\My311LA_project\Views\my311_with_popdensity_view6.csv'
CSV HEADER;

COPY (SELECT * FROM neighborhood_requests) to 'G:\PostgresSQL\Projects\My311LA_project\Views\neighborhood_requests_view7.csv'
CSV HEADER;

COPY (SELECT * FROM reqtype_reqsrc) to 'G:\PostgresSQL\Projects\My311LA_project\Views\reqtype_reqsrc_view8.csv'
CSV HEADER;

COPY (SELECT * FROM request_type_month_percentage) to 'G:\PostgresSQL\Projects\My311LA_project\Views\request_type_month_percentage_view9.csv'
CSV HEADER;

COPY (SELECT * FROM requests_by_neighborhood_requesttype) to 'G:\PostgresSQL\Projects\My311LA_project\Views\requests_by_neighborhood_requesttype_view10.csv'
CSV HEADER;

COPY (SELECT * FROM requesttype_with_requestsource) to 'G:\PostgresSQL\Projects\My311LA_project\Views\requesttype_with_requestsource_view11.csv'
CSV HEADER;

COPY (SELECT * FROM requesttype_with_requestsource_v2) to 'G:\PostgresSQL\Projects\My311LA_project\Views\requesttype_with_requestsource_v2_view12.csv'
CSV HEADER;

COPY (SELECT * FROM self_service_by_reqtype) to 'G:\PostgresSQL\Projects\My311LA_project\Views\self_service_by_reqtype_view13.csv'
CSV HEADER;

COPY (SELECT * FROM Average_ticket_closed) to 'G:\PostgresSQL\Projects\My311LA_project\Views\Average_ticket_closed_view14.csv'
CSV HEADER;



SELECT * FROM requests_by_neighborhood_requesttype;