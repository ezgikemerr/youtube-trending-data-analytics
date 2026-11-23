USE DATABASE assignment_1;


--PART 4: Business Question-->Provide a single sql file containing all the queries used:
--If you were to launch a new Youtube channel tomorrow, which category (excluding “Music” and “Entertainment”) of video will you be trying to create to have them appear in the top trend of Youtube? Will this strategy work in every country?

-- Query 1 → Overall Category Analysis: To address the business question, the analysis was conducted in two stages. First, the overall distribution of distinct trending videos across categories was examined, excluding Music and Entertainment as specified in the question. This analysis was used to identify the category with the strongest overall representation in the YouTube trending dataset.

SELECT
    category_title,
    COUNT(DISTINCT video_id) AS total_distinct_videos
FROM table_youtube_final
WHERE category_title NOT IN ('Music', 'Entertainment')
GROUP BY category_title
ORDER BY total_distinct_videos DESC;


-- Query 2 → Country-Level Analysis: Second, the analysis was extended to the country level to determine whether the category identified as the strongest overall also performed consistently across different countries. For each country, the category with the highest number of distinct trending videos was identified. This allows the overall recommendation to be evaluated against regional differences and helps determine whether a single global content strategy would be appropriate.


SELECT
    country,
    category_title,
    COUNT(DISTINCT video_id) AS total_distinct_videos
FROM table_youtube_final
WHERE category_title NOT IN ('Music', 'Entertainment')
GROUP BY country, category_title
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY country
    ORDER BY COUNT(DISTINCT video_id) DESC
) = 1
ORDER BY country;

--Results & Business Interpretation:The overall analysis shows that, after excluding Music and Entertainment, Sports has the highest number of distinct videos appearing in the YouTube trending dataset, with 43,323 distinct videos. This is followed closely by People & Blogs (42,876) and Gaming (41,615). Based on overall representation in the historical trending data, Sports would therefore be the preferred category for launching a new YouTube channel if the objective is to select a category that has frequently appeared in trending content. (Query1)

--However, the country-level analysis demonstrates that this strategy is not consistent across all markets. Sports is the leading category in only Brazil, Germany, and Great Britain. In contrast, Gaming is the leading category in Canada, France, Japan, Mexico, and the United States, while People & Blogs leads in India and South Korea.

--Therefore, a single global category strategy may not be optimal. Although Sports has the strongest overall representation, the results indicate meaningful differences between countries. A more appropriate business strategy would be to adapt the content category to the target market, particularly considering Gaming for several markets and People & Blogs for India and South Korea.

--Importantly, these results are based on the historical representation of distinct videos in the trending dataset. They indicate which categories have appeared most frequently among trending videos, but do not establish that selecting a particular category will cause a new video to trend.
