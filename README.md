Steps to Get Started

Step 1: Download the Dataset

Download the following CSV files from this repository:

movies.csv: Contains movie information (movie ID, title, genres).

ratings.csv: Contains user ratings (user ID, movie ID, rating, date_rated).

You can save the files to a directory on your local machine.

Step 2: Set Up the Database

1. Create the Database

Run the following query in SQL Server Management Studio (SSMS) to create a new database for the analysis:

CREATE DATABASE movies;

USE movies;

2. Load the Dataset into SQL Server
Use the BULK INSERT command to load the ratings.csv and movies.csv files into SQL Server tables.

For the movies table:

BULK INSERT MOVIES
FROM 'path\to\movies.csv'
WITH (
    FIELDTERMINATOR = ',',  -- Define the field delimiter as a comma
    ROWTERMINATOR = '\n',   -- Define the row delimiter as a newline
    FIRSTROW = 2            -- Skip the header row
);

For the ratings table:

BULK INSERT RATINGS
FROM 'path\to\ratings.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2            
);

Note: Replace path\to\movies.csv and path\to\ratings.csv with the actual file paths on your machine.

Step 3: Perform Analysis from the SQL file given
