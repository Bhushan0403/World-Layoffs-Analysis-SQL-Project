SELECT *
FROM layoffs;

-- Data Cleaning Process
-- Remove duplicates
-- Standardize the data
-- Adjust null values or blank values
-- Remove irrelevant columns or rows

-- We can't do this in our original dataset, so we'll use staging. This means we copy all original data from the layoffs table into the layoffs_staging table.

CREATE TABLE layoff_staging LIKE layoffs;

SELECT * FROM layoff_staging;
-- This will just create the columns like the original table, now we need to insert all values into the new table.

INSERT INTO layoff_staging
SELECT * FROM layoffs;

SELECT * FROM layoff_staging;
-- Now we have an exact duplicate table as the original one, now we perform all querying on the new table.

----------------------------------------------------------------------------------------------------------

-- Now, the first thing in data cleaning is to remove duplicates.
-- Here, there is no column that shows unique rows, so we create a new column that assigns a unique row number to each row against each column.

-- First, we identify the duplicates.

SELECT *,
ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoff_staging;

-- We need to create a CTE to check the values in the row_num column which are greater than 1; those are the duplicates.

WITH duplicate_cte AS (
  SELECT *,
  ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
  ) AS row_num
  FROM layoff_staging
)
SELECT * FROM duplicate_cte WHERE row_num > 1;

-- Check any company to see if there are duplicate rows.
SELECT * FROM layoff_staging WHERE company = "Casper";
-- We only want to remove duplicate rows and keep the original one, not delete both.

-- To remove the duplicates, we need to create a new table (staging2) where the "row_num" column is part of the original table, so we can delete the duplicate row_num > 1.

CREATE TABLE `layoff_staging2` (
  `company` TEXT,
  `location` TEXT,
  `industry` TEXT,
  `total_laid_off` INT DEFAULT NULL,
  `percentage_laid_off` TEXT,
  `date` TEXT,
  `stage` TEXT,
  `country` TEXT,
  `funds_raised_millions` INT DEFAULT NULL,
  `row_num` INT -- Insert new column row_num
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoff_staging2; -- This will create a new table with columns.

-- Need to insert values.

INSERT INTO layoff_staging2
SELECT *,
ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoff_staging;

SELECT * FROM layoff_staging2; -- This will have the new table with assigned row_num.

-- Now we can filter duplicate rows by checking row_num > 1.

SELECT *
FROM layoff_staging2
WHERE row_num > 1; -- Retrieve all duplicates.

-- Now we can delete these duplicate results.

DELETE
FROM layoff_staging2
WHERE row_num > 1;

SELECT *
FROM layoff_staging2;

-- We can delete the row_num column later in this process as this will not be useful anymore.
-- We do this long process as we do not have a unique column to identify the duplicates.

-------------------------------------------------------------------------------------------------------------

-- Now, the next step is standardizing data.
-- To standardize the data, first we need to check all columns one by one with their distinct values, then perform the required actions.

-- To remove any extra spaces before and after the text in the company column.

UPDATE layoff_staging2
SET company = TRIM(company);

SELECT *
FROM layoff_staging2;

SELECT DISTINCT industry
FROM layoff_staging2
ORDER BY 1;

-- After reviewing the data, we can see that there are multiple records related to the "crypto" industry.

SELECT *
FROM layoff_staging2
WHERE industry LIKE "crypto%";

-- Now we standardize all crypto-related industry records to the standard "Crypto".

UPDATE layoff_staging2
SET industry = "Crypto"
WHERE industry LIKE "crypto%";

-- Now check if there is only one distinct "Crypto" record.
SELECT DISTINCT industry
FROM layoff_staging2;

-- Checking all other columns as well to see if there is any unstandardized format found.

SELECT DISTINCT country
FROM layoff_staging2
ORDER BY country;
-- There are multiple forms of "United States," we should standardize to common format.

UPDATE layoff_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE "United States%";

SELECT *
FROM layoff_staging2;

-- Now when looking at the `date` column, the datatype of the column should be DATE so we can perform time series data analysis,
-- but here it is TEXT datatype so we need to change the datatype of the `date` column.

SELECT `date`
FROM layoff_staging2;

UPDATE layoff_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoff_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoff_staging2;

-----------------------------------------------------------------------------------------------------------

-- Now, the next step is adjusting null values or blank values.

SELECT *
FROM layoff_staging2
WHERE industry IS NULL OR industry = '';

-- We can do a self join to see if there is industry data populated for the same company.

SELECT t1.company, t1.industry, t2.industry
FROM layoff_staging2 t1
JOIN layoff_staging2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- From this, we get to know which company has which industry, for example, some "Airbnb" records have industry present as "Travel".
-- So now first we need to convert all blank records to NULL first.

UPDATE layoff_staging2
SET industry = NULL
WHERE industry = '';

-- Now we can actually update table1 industry column from the record in table2 industry column.

UPDATE layoff_staging2 t1
JOIN layoff_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Done, we can check if it fills the blank industry records.

SELECT *
FROM layoff_staging2
WHERE company = "Airbnb";

-- Now check other columns as well.

SELECT *
FROM layoff_staging2
WHERE total_laid_off IS NULL OR total_laid_off = '';

SELECT *
FROM layoff_staging2
WHERE percentage_laid_off IS NULL OR percentage_laid_off = '';

SELECT *
FROM layoff_staging2
WHERE funds_raised_millions IS NULL OR funds_raised_millions = '';

-- There are blank and null values in total_laid_off, percentage_laid_off, and funds_raised_millions, but we cannot populate data for those
-- as we don't have enough data to do this.

SELECT *
FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- We can delete these rows as both total_laid_off and percentage_laid_off have null values for these records. We don't need these null records.

DELETE
FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; -- Deleted all null data as this is not usable.

SELECT *
FROM layoff_staging2;

-- Now we can delete the row_num column as we don't need this anymore.

ALTER TABLE layoff_staging2
DROP COLUMN row_num;

-- Now we have clean data for layoffs. Further, we will do exploratory data analysis on this clean data.

SELECT *
FROM layoff_staging2;
