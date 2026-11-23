USE DATABASE assignment_1;

-- Question 1:In “table_youtube_category” which category_title has duplicates if we don’t take into account the categoryid (return only a single row)?
-- Find the category_title associated with multiple category IDs--> Answer: Comedy

SELECT category_title
FROM table_youtube_category
GROUP BY category_title
HAVING COUNT(DISTINCT categoryid) > 1
LIMIT 1;


-- Question 2:In “table_youtube_category” which category_title only appears in one country?
-- Find to which category_title only appears in one country--> Answer: Nonprofits & Activism

SELECT category_title
FROM table_youtube_category
GROUP BY category_title
HAVING COUNT(DISTINCT country) = 1;


-- Question 3:In “table_youtube_final”, what is the categoryid of the missing category_title?
-- Find to what is the categoryid of the missing category_title--> Answer:categoryid: 29

SELECT DISTINCT categoryid
FROM table_youtube_final
WHERE category_title IS NULL;


-- Question 4: Update the table_youtube_final to replace the NULL values in category_title with the answer from the previous question.
-- Replace NULL category_title values with the answer from Question 3--> (Answer from Question 3: 29)

UPDATE table_youtube_final
SET category_title = '29'
WHERE category_title IS NULL;


--Just for checking to table
SELECT COUNT(*)
FROM table_youtube_final
WHERE category_title IS NULL;


-- Question 5:In “table_youtube_final”, which video doesn’t have a channeltitle (return only the title)?
-- Find to which video does not have a channeltitle? Answer: Kala Official Teaser | Tovino Thomas | Rohith V S | Juvis Productions | Adventure Company

SELECT title
FROM table_youtube_final
WHERE channeltitle IS NULL;


-- Question 6: Delete from “table_youtube_final“, any record with video_id = “#NAME?”
-- Delete any record with video_id = '#NAME?'--> Answer: All records with video_id = '#NAME?' were removed.Check to table shows that 0 #name?.

DELETE FROM table_youtube_final
WHERE video_id = '#NAME?';


--Just for checking the table
SELECT COUNT(*)
FROM table_youtube_final
WHERE video_id = '#NAME?';

-- Question 7: Create a new table called “table_youtube_duplicates”  containing only the “bad” duplicates by using the row_number() function.
-- "bad" duplicates using ROW_NUMBER()--> Result: 37,466 bad duplicate records identified.


CREATE OR REPLACE TABLE table_youtube_duplicates AS
SELECT *
FROM table_youtube_final
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY video_id, country, trending_date
    ORDER BY view_count DESC
) > 1;


--Just for checking table
SELECT COUNT(*)
FROM table_youtube_duplicates;


-- Question 8: Delete the duplicates in “table_youtube_final“ by using “table_youtube_duplicates”.
-- Result --> 37,466 duplicate records were deleted.

DELETE FROM table_youtube_final
WHERE id IN (
    SELECT id
    FROM table_youtube_duplicates
);


-- Question 9 : Count the rows in table_youtube_final and check
-- that the final row count is 2,597,494.


SELECT COUNT(*)
FROM table_youtube_final;