/*
Write a query to find out how many movies are associated with each genre. 
Split the genres column to count the occurrence of each genre.
*/
SELECT VALUE AS GENRE, COUNT(*) AS NO_OF_MOVIES
FROM MOVIES
CROSS APPLY STRING_SPLIT(GENRES, '|')
GROUP BY VALUE
ORDER BY GENRE;

--Write a query to find the top 5 highest-rated movies based on the average rating.
SELECT TOP 5 M.TITLE,AVG(R.RATING) RATING FROM MOVIES M LEFT JOIN RATINGS R ON M.MOVIEID = R.MOVIEID 
GROUP BY M.TITLE ORDER BY RATING DESC

--Identify the user who has rated the most movies and calculate their average rating.
SELECT TOP 1 USERID,COUNT(MOVIEID) NO_OF_MOVIES_RATED,AVG(RATING) AVG_RATING_GIVEN FROM RATINGS 
GROUP BY USERID ORDER BY NO_OF_MOVIES_RATED DESC,AVG_RATING_GIVEN DESC

/*Calculate the average rating for each genre. For example,
find the average rating of "Comedy" movies, "Adventure" movies, etc.*/
SELECT VALUE AS GENRE,AVG(CAST(R.RATING AS FLOAT)) AS AVERAGE_RATING FROM MOVIES M
CROSS APPLY STRING_SPLIT(M.GENRES, '|')
LEFT JOIN RATINGS R ON M.MOVIEID = R.MOVIEID
GROUP BY VALUE ORDER BY AVERAGE_RATING DESC;

--Write a query to count how many movies each user has rated
SELECT USERID,COUNT(DISTINCT MOVIEID) NO_OF_MOVIES_RATED FROM RATINGS GROUP BY USERID

/*
Retrieve the movies rated in the last 6 months
*/
SELECT * FROM RATINGS WHERE DATE_RATED >= DATEADD(MONTH, -6, GETDATE());

--Find the genres for which no user has given a rating.
SELECT VALUE AS GENRE,COUNT(R.MOVIEID) NO_OF_RATING FROM MOVIES M CROSS APPLY STRING_SPLIT(GENRES,'|') LEFT JOIN RATINGS R ON M.MOVIEID=R.MOVIEID
GROUP BY VALUE HAVING COUNT(R.MOVIEID) = 0

--Find which genre is the most popular among all users (based on the number of ratings).
SELECT TOP 1 VALUE AS GENRE,COUNT(R.MOVIEID) NO_OF_RATING FROM MOVIES M CROSS APPLY STRING_SPLIT(GENRES,'|') LEFT JOIN RATINGS R ON M.MOVIEID=R.MOVIEID
GROUP BY VALUE ORDER BY NO_OF_RATING DESC

--Write a query to count the number of ratings in each rating bucket (e.g., 0-1, 1-2, 2-3, etc.).
SELECT 
    COUNT(CASE WHEN RATING >= 0 AND RATING < 1 THEN 1 END) AS WORST,
    COUNT(CASE WHEN RATING >= 1 AND RATING < 2 THEN 1 END) AS BAD,
    COUNT(CASE WHEN RATING >= 2 AND RATING < 3 THEN 1 END) AS AVERAGE,
    COUNT(CASE WHEN RATING >= 3 AND RATING < 4 THEN 1 END) AS GOOD,
    COUNT(CASE WHEN RATING >= 4 AND RATING <= 5 THEN 1 END) AS EXCELLENT
FROM RATINGS;

--Write a query to find if there are users who have rated the same movie more than once.
SELECT USERID,MOVIEID,COUNT(MOVIEID) TIMES_RATED FROM RATINGS GROUP BY USERID,MOVIEID HAVING COUNT(MOVIEID)>1

/* Find movies that have an average rating of less than 3 but belong to genres typically considered popular, 
such as "Adventure" or "Animation."
*/
SELECT R.MOVIEID,TITLE,VALUE,AVG(RATING) AVG_RATING FROM MOVIES M CROSS APPLY STRING_SPLIT(GENRES,'|')
LEFT JOIN RATINGS R ON M.MOVIEID=R.MOVIEID GROUP BY R.MOVIEID,VALUE,TITLE 
HAVING AVG(RATING) < 3 AND (VALUE = 'Adventure' OR VALUE = 'Animation')

/*Identify trends in user ratings over time. For example, do users tend to rate higher as time progresses? 
Group by year (based on the DATE) and calculate the average rating.
*/
SELECT YEAR(DATE_RATED) YEAR,COUNT(*) NO_OR_RATINGS,AVG(RATING) AVG_RATING FROM RATINGS 
GROUP BY YEAR(DATE_RATED) ORDER BY YEAR

/*
Find pairs of movies that have been rated by the same user. For each pair, 
calculate the number of users who have rated both movies.
*/
SELECT R1.MOVIEID,R2.MOVIEID,COUNT(R1.USERID) NO_OF_USERS_RATED FROM RATINGS R1 
JOIN RATINGS R2 ON R1.MOVIEID < R2.MOVIEID AND R1.MOVIEID <> R2.MOVIEID
GROUP BY R1.MOVIEID,R2.MOVIEID

--Find the user with the gap between their first and last ratings, and calculate the gap in days.
SELECT TOP 1 USERID, DATEDIFF(DAY, MIN(DATE_RATED), MAX(DATE_RATED)) AS GAP_IN_DAYS FROM RATINGS
GROUP BY USERID ORDER BY GAP_IN_DAYS DESC;

--Find users who have rated movies from the highest number of distinct genres.
SELECT TOP 1 USERID,COUNT(DISTINCT GENRE.VALUE) NO_OF_GENRE FROM MOVIES M CROSS APPLY STRING_SPLIT(GENRES,'|') GENRE
LEFT JOIN RATINGS R ON M.MOVIEID = R.MOVIEID WHERE USERID IS NOT NULL GROUP BY USERID ORDER BY NO_OF_GENRE DESC,USERID

--Group ratings by year and genre to determine the top-rated genre for each year.
WITH GenreRatings AS (
SELECT YEAR(R.DATE_RATED) AS YEAR,GENRE.VALUE AS GENRE,AVG(R.RATING) AS AVG_RATING
FROM MOVIES M CROSS APPLY STRING_SPLIT(M.GENRES, '|') AS GENRE
LEFT JOIN RATINGS R ON M.MOVIEID = R.MOVIEID WHERE R.DATE_RATED IS NOT NULL
GROUP BY YEAR(R.DATE_RATED), GENRE.VALUE
),
RankedGenres AS (
SELECT YEAR,GENRE,AVG_RATING,RANK() OVER (PARTITION BY YEAR ORDER BY AVG_RATING DESC) AS RANK
FROM GenreRatings
)
SELECT YEAR, GENRE, AVG_RATING FROM RankedGenres WHERE RANK = 1 ORDER BY YEAR;

--Find movies that belong to only a single genre (e.g., movies with no "|" in the genres column)
SELECT * FROM MOVIES WHERE PATINDEX('%|%',GENRES) = 0
SELECT * FROM MOVIES WHERE GENRES NOT LIKE '%|%'

/*Find movies that belong to only a single genre (e.g., movies with no "|" in the genres column)
and their average rating.*/
SELECT M.GENRES,AVG(ISNULL(R.RATING, 0)) AS AVG_RATING FROM MOVIES M LEFT JOIN RATINGS R ON M.MOVIEID=R.MOVIEID 
WHERE M.GENRES NOT LIKE '%|%' GROUP BY M.GENRES

--Identify movies that have been rated by all users in the dataset.
WITH CTE AS 
(
SELECT COUNT(DISTINCT USERID) TOTAL_USERS FROM RATINGS
)
SELECT MOVIEID FROM RATINGS GROUP BY MOVIEID HAVING COUNT(DISTINCT USERID) = (SELECT TOTAL_USERS FROM CTE)

/*Compare the average ratings of older movies (e.g., released before the year 2000) with newer movies
(e.g., released after the year 2000). */
SELECT 'BEFORE 2000' AS CATEGORY, AVG(R.RATING) AS AVG_RATING FROM RATINGS R 
LEFT JOIN MOVIES M ON R.MOVIEID = M.MOVIEID
WHERE COALESCE(TRY_CAST(SUBSTRING(M.TITLE, LEN(M.TITLE) - 4, 4) AS INT), 0) < 2000
UNION ALL
SELECT 'AFTER 2000' AS CATEGORY, AVG(R.RATING) AS AVG_RATING FROM RATINGS R 
LEFT JOIN MOVIES M ON R.MOVIEID = M.MOVIEID
WHERE COALESCE(TRY_CAST(SUBSTRING(M.TITLE, LEN(M.TITLE) - 4, 4) AS INT), 0) >= 2000;

--For each movie, calculate the percentage of users who have rated it compared to the total number of users
WITH CTE AS 
(
SELECT COUNT(DISTINCT USERID) TOTAL_USERS FROM RATINGS
)
SELECT MOVIEID,(COUNT(DISTINCT USERID) * 100.0 / (SELECT TOTAL_USERS FROM CTE)) PERCENTAGE FROM RATINGS GROUP BY MOVIEID

--Find movies that have received very few ratings (e.g., less than 5) but have an average rating of 4 or higher.
SELECT M.MOVIEID,M.TITLE FROM MOVIES M 
LEFT JOIN RATINGS R ON M.MOVIEID=R.MOVIEID GROUP BY M.MOVIEID,M.TITLE 
HAVING COUNT(R.RATING) < 5 AND AVG(R.RATING) >= 4

/*Find the genres where users consistently give high ratings (e.g., average rating > 4). 
Highlight users who predominantly rate movies in these genres. */
WITH CTE AS
(SELECT GENRE.VALUE GENRE FROM MOVIES M CROSS APPLY STRING_SPLIT(M.GENRES, '|') AS GENRE 
LEFT JOIN RATINGS R ON M.MOVIEID = R.MOVIEID
GROUP BY GENRE.VALUE
HAVING AVG(R.RATING) > 4
)
SELECT R.USERID,GENRE.VALUE AS GENRE FROM MOVIES M  CROSS APPLY STRING_SPLIT(M.GENRES, '|') AS GENRE
LEFT JOIN CTE ON GENRE.VALUE = CTE.GENRE
LEFT JOIN RATINGS R ON M.MOVIEID = R.MOVIEID
WHERE R.USERID IS NOT NULL
