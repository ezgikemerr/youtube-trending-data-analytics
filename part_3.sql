USE DATABASE assignment_1;


-- Question 1:
-- What are the 3 most viewed videos for each country
-- in the Gaming category for trending_date = '2024-04-01'?
-- This analysis shows that order the result by country and rank.


SELECT
    country,
    title,
    channeltitle,
    view_count,
    ROW_NUMBER() OVER (
        PARTITION BY country
        ORDER BY view_count DESC
    ) AS rk
FROM table_youtube_final
WHERE category_title = 'Gaming'
  AND trending_date = '2024-04-01'
QUALIFY rk <= 3
ORDER BY country, rk;


-- Question 2:
-- For each country, count the number of distinct videos
-- with a title containing "BTS" (case insensitive).
-- Order the result by count in descending order.


SELECT
    country,
    COUNT(DISTINCT video_id) AS ct
FROM table_youtube_final
WHERE title ILIKE '%BTS%'
GROUP BY country
ORDER BY ct DESC;

-- Question 3: For each country, year and month (in a single column) and only for the year 2024, which video is the most viewed and what is its likes_ratio (defined as the percentage of likes against view_count) truncated to 2 decimals. Order the result by year_month and country.


SELECT
    country,
    DATE_TRUNC('MONTH', trending_date) AS year_month,
    title,
    channeltitle,
    category_title,
    view_count,
    TRUNC((likes / NULLIF(view_count, 0)) * 100, 2) AS likes_ratio
FROM table_youtube_final
WHERE YEAR(trending_date) = 2024
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY country, DATE_TRUNC('MONTH', trending_date)
    ORDER BY view_count DESC
) = 1
ORDER BY year_month, country;

-- Question 4: For each country, which category_title has the most distinct videos and what is its percentage (2 decimals) out of the total distinct number of videos of that country? Only look at the data from 2022. Order the result by category_title and country.


WITH category_counts AS (
    SELECT
        country,
        category_title,
        COUNT(DISTINCT video_id) AS total_category_video
    FROM table_youtube_final
    WHERE trending_date >= '2022-01-01'
    GROUP BY country, category_title
),

country_counts AS (
    SELECT
        country,
        COUNT(DISTINCT video_id) AS total_country_video
    FROM table_youtube_final
    WHERE trending_date >= '2022-01-01'
    GROUP BY country
)

SELECT
    c.country,
    c.category_title,
    c.total_category_video,
    t.total_country_video,
    ROUND(
        c.total_category_video * 100.0 / t.total_country_video,
        2
    ) AS percentage
FROM category_counts c
JOIN country_counts t
    ON c.country = t.country
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY c.country
    ORDER BY c.total_category_video DESC
) = 1
ORDER BY c.category_title, c.country;


--Question 5: Which channeltitle has produced the most distinct videos and what is this number?
--Answer: Vijay Television — 2,049 distinct videos


SELECT
    channeltitle,
    COUNT(DISTINCT video_id) AS total_distinct_videos
FROM table_youtube_final
GROUP BY channeltitle
ORDER BY total_distinct_videos DESC
LIMIT 1;



