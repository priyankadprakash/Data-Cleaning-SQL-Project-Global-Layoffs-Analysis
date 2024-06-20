-- Exploratory Data Analysis --

SELECT * 
FROM layoffs_staging2;

SELECT MAX(total_laid_off) , MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company , SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;

SELECT MIN(`date`) , MAX(`date`)
FROM layoffs_staging2;

SELECT industry , SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

SELECT country , SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

SELECT YEAR(`date`) , SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) DESC;

SELECT stage , SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY stage
ORDER BY SUM(total_laid_off) DESC;

SELECT SUBSTRING(`date` , 1,7) AS `MONTH` , SUM(total_laid_off) 
FROM layoffs_staging2
WHERE SUBSTRING(`date` , 1,7) IS NOT NULL
GROUP BY `month`
ORDER BY `month`;

-- Rolling Total --

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date` , 1,7) AS `MONTH` , SUM(total_laid_off) AS laid_off
FROM layoffs_staging2
WHERE SUBSTRING(`date` , 1,7) IS NOT NULL
GROUP BY `month`
ORDER BY `month`
)
SELECT `month` ,laid_off, SUM(laid_off) 
OVER (ORDER BY `month` ) AS rolling_total
FROM Rolling_Total;


SELECT company , YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company , YEAR(`date`)
ORDER BY SUM(total_laid_off) DESC;


WITH Company_Year (company , years , total_laid_off) AS
(
SELECT company , YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company , YEAR(`date`)
) , Company_Year_Rank AS
(SELECT * , 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL 
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5;

-- Percentage Layoff --

WITH yearly_layoffs AS (
    SELECT 
        EXTRACT(YEAR FROM `date`) AS Year,
        SUM(total_laid_off) AS TotalLayoffs
    FROM layoffs_staging2
    WHERE industry = 'healthcare'
    GROUP BY Year
)
SELECT 
    y1.`year` AS PreviousYear,
    y2.`year` AS CurrentYear,
    y1.TotalLayoffs AS LayoffsPreviousYear,
    y2.TotalLayoffs AS LayoffsCurrentYear,
    ((y2.TotalLayoffs - y1.TotalLayoffs) / y1.TotalLayoffs) * 100 AS PercentageIncrease
FROM 
    yearly_layoffs y1
JOIN 
    yearly_layoffs y2
ON 
    y1.Year = y2.Year - 1
WHERE 
    y1.Year = 2022;
    
    
    
select * 
from layoffs_staging2;

WITH MarketingLayoffs AS (
    SELECT 
        SUM(total_laid_off) AS TotalMarketingLayoffs
    FROM 
        layoffs_staging2
    WHERE 
        industry = 'Marketing'
) , GlobalLayoffs AS (
    SELECT 
        SUM(total_laid_off) AS TotalGlobalLayoffs
    FROM 
        layoffs
)
SELECT 
    MarketingLayoffs.TotalMarketingLayoffs,
    GlobalLayoffs.TotalGlobalLayoffs,
    (MarketingLayoffs.TotalMarketingLayoffs * 100.0 / GlobalLayoffs.TotalGlobalLayoffs) AS MarketingLayoffPercentage
FROM 
    MarketingLayoffs, 
    GlobalLayoffs;



