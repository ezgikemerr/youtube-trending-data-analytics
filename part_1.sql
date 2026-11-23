--PartA: 
--1.Downloaded dataset on Azure, 
--2.Uploaded the data set in my storage account on Azure.

--3.Create database and create stage--> Connect to azure storage.

CREATE DATABASE assignment_1;
USE DATABASE assignment_1;

CREATE OR REPLACE STAGE stage_assignment
URL = 'azure://<YOUR_STORAGE_ACCOUNT>.blob.core.windows.net/<YOUR_CONTAINER>'
CREDENTIALS = (AZURE_SAS_TOKEN = '<YOUR_AZURE_SAS_TOKEN>');

LIST @stage_assignment;


-- 4a. Create external table for YouTube trending CSV data

CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending
WITH LOCATION = @stage_assignment
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
)
PATTERN = '.*youtube_trending_data[.]csv';

SELECT *
FROM ex_table_youtube_trending;


-- 4a. Create external table for YouTube category JSON data

CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_category
WITH LOCATION = @stage_assignment
FILE_FORMAT = (
    TYPE = JSON
)
PATTERN = '.*category_id[.]json';


SELECT *
FROM ex_table_youtube_category
LIMIT 10;


-- 5a. Create table_youtube_trending from external table

CREATE OR REPLACE TABLE table_youtube_trending AS
SELECT
    VALUE:c1::VARCHAR AS video_id,
    VALUE:c2::VARCHAR AS title,
    TO_DATE(VALUE:c3::VARCHAR) AS publishedat,
    VALUE:c4::VARCHAR AS channelid,
    VALUE:c5::VARCHAR AS channeltitle,
    VALUE:c6::NUMBER AS categoryid,
    TO_DATE(VALUE:c7::VARCHAR) AS trending_date,
    VALUE:c8::NUMBER AS view_count,
    VALUE:c9::NUMBER AS likes,
    VALUE:c10::NUMBER AS dislikes,
    VALUE:c11::NUMBER AS comment_count,
    SPLIT_PART(METADATA$FILENAME, '_', 1)::VARCHAR AS country
FROM ex_table_youtube_trending;


SELECT *
FROM table_youtube_trending
LIMIT 4;

-- 5b. Create table_youtube_category from external table

CREATE OR REPLACE TABLE table_youtube_category AS
SELECT
    SPLIT_PART(METADATA$FILENAME, '_', 1)::VARCHAR AS country,
    f.value:id::NUMBER AS categoryid,
    f.value:snippet:title::VARCHAR AS category_title
FROM ex_table_youtube_category,
LATERAL FLATTEN(INPUT => VALUE:items) f;


SELECT *
FROM table_youtube_category
LIMIT 6;

-- 6. Create table_youtube_final

CREATE OR REPLACE TABLE table_youtube_final AS
SELECT
    UUID_STRING() AS id,
    t.video_id,
    t.title,
    t.publishedat,
    t.channelid,
    t.channeltitle,
    t.categoryid,
    c.category_title,
    t.trending_date,
    t.view_count,
    t.likes,
    t.dislikes,
    t.comment_count,
    t.country
FROM table_youtube_trending AS t
LEFT JOIN table_youtube_category AS c
    ON t.country = c.country
    AND t.categoryid = c.categoryid;

SELECT *
FROM table_youtube_final
LIMIT 5;


SELECT COUNT(*)
FROM table_youtube_final;