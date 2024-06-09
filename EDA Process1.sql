-- Exploratory Data Analysis

-- After cleaning the data, we just explore the dataset to see what insights we can get from the data 

-- 1. What is the maximum number of layoffs in a single day?
SELECT MAX(total_laid_off) AS Maximum_Layoffs
FROM layoff_staging2;

-- 2. Which companies had 100% layoffs and what were their funds raised?
SELECT *
FROM layoff_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- 3. What are the total layoffs by each company?
SELECT company, SUM(total_laid_off) AS Total_Layoffs
FROM layoff_staging2
GROUP BY company
ORDER BY Total_Layoffs DESC;

-- 4. What are the total layoffs by industry?
SELECT industry, SUM(total_laid_off) AS Total_Layoffs
FROM layoff_staging2
GROUP BY industry
ORDER BY Total_Layoffs DESC;

-- 5. What are the total layoffs by country?
SELECT country, SUM(total_laid_off) AS Total_Layoffs
FROM layoff_staging2
GROUP BY country
ORDER BY Total_Layoffs DESC;

-- 6. Which companies had the maximum layoffs in a single day?
SELECT company, MAX(total_laid_off) AS SingleDay_MaxLayoffs
FROM layoff_staging2
GROUP BY company
ORDER BY MAX(total_laid_off) DESC;

-- 7. How many layoffs occurred each year?
SELECT YEAR(`date`) AS Year, SUM(total_laid_off) AS Total_Layoffs
FROM layoff_staging2
GROUP BY YEAR(`date`)
ORDER BY Total_Layoffs DESC;

-- 8. What are the rolling total layoffs by month?
WITH Rolling_Total AS 
(
    SELECT SUBSTRING(`date`, 1, 7) AS `Month`, SUM(total_laid_off) AS Total_Layoffs
    FROM layoff_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `Month`
    ORDER BY `Month`
)
SELECT `Month`, Total_Layoffs, SUM(Total_Layoffs) OVER(ORDER BY `Month`) AS Rolling_Total_Layoffs
FROM Rolling_Total;

-- 9. What are the top 5 companies with the most layoffs each year?
WITH Company_Year AS 
(
    SELECT company, YEAR(`date`) AS `Year`, SUM(total_laid_off) AS Total_Layoffs
    FROM layoff_staging2
    GROUP BY company, `Year`
),
Company_Year_Rank AS
(
    SELECT *,
    DENSE_RANK() OVER (PARTITION BY `Year` ORDER BY Total_Layoffs DESC) AS Ranking
    FROM Company_Year
    WHERE `Year` IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;


-- 10. How do monthly layoffs trend over time, and which months have the highest and lowest layoffs?
WITH Monthly_Layoffs AS (
    SELECT 
        DATE_FORMAT(`date`, '%Y-%m') AS month,
        SUM(total_laid_off) AS total_layoffs
    FROM 
        layoff_staging2
    GROUP BY 
        month
    ORDER BY 
        month
),
Monthly_Stats AS (
    SELECT 
        month,
        total_layoffs,
        LAG(total_layoffs) OVER (ORDER BY month) AS previous_month_layoffs,
        Round((total_layoffs - LAG(total_layoffs) OVER (ORDER BY month)) 
        / NULLIF(LAG(total_layoffs) OVER (ORDER BY month), 0) * 100,2) AS percentage_change
    FROM 
        Monthly_Layoffs
)
SELECT 
    month,
    total_layoffs,
    previous_month_layoffs,
    percentage_change
FROM 
    Monthly_Stats;












