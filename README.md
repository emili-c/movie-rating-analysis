# movie-rating-analysis
analyze the movies and their ratings


step 1 : download CSV files
step 2 : run below queries
        
        create database movies
        
        use movies 
        
        BULK INSERT RATINGS
        FROM 'path\to\ratings.csv'
        WITH (
            FIELDTERMINATOR = ',',  
            ROWTERMINATOR = '\n',  
            FIRSTROW = 2           
        );
        
        BULK INSERT RATINGS
        FROM 'path\to\ratings.csv'
        WITH (
            FIELDTERMINATOR = ',',  
            ROWTERMINATOR = '\n',  
            FIRSTROW = 2           
        );
