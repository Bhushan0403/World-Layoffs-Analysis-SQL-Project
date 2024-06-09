# World Layoffs Analysis

## Objective

### Data Cleaning Process
Prepare and standardize the dataset by removing duplicates, handling null values, standardizing data formats, and removing irrelevant data to ensure accurate and reliable analysis.

### Exploratory Data Analysis (EDA)
Extract meaningful insights from the cleaned data by identifying key metrics, analyzing trends, evaluating company performance, and exploring correlations.

## Data Cleaning Process

1. **Remove Duplicates:**
   - Created a staging table (`layoff_staging`) and copied the original data.
   - Identified and removed duplicate records by assigning unique row numbers.

2. **Standardize Data:**
   - Trimmed extra spaces from text fields.
   - Standardized industry names and country formats.
   - Converted `date` column from text to date format.

3. **Handle Null Values:**
   - Updated null values in the `industry` column based on available data.
   - Deleted records where critical fields (like `total_laid_off` and `percentage_laid_off`) were null.

4. **Remove Irrelevant Data:**
   - Dropped unnecessary columns (e.g., `row_num` after handling duplicates).

## Exploratory Data Analysis (EDA)

### Key Insights

1. **Maximum Layoffs in a Single Day:**
   Identified the highest number of layoffs recorded in a single day.

2. **Companies with 100% Layoffs:**
   Showed companies that laid off all their employees, along with their funding details.

3. **Total Layoffs by Company:**
   Highlighted companies with the highest total layoffs.

4. **Total Layoffs by Industry:**
   Identified industries most affected by layoffs.

5. **Total Layoffs by Country:**
   Provided a geographical perspective on layoffs.

6. **Maximum Layoffs by Company in a Single Day:**
   Identified companies with the highest single-day layoffs.

7. **Annual Layoffs:**
   Showed the number of layoffs that occurred each year.

8. **Rolling Total Layoffs by Month:**
   Displayed cumulative layoffs over time, useful for identifying trends.

9. **Top 5 Companies with Most Layoffs Each Year:**
   Listed top companies with the most layoffs annually.

10. **Monthly Layoffs Trend:**
    Tracked layoffs monthly and highlighted percentage changes, identifying peaks and declines.

## Special Thanks

A special thank you to Alex The Analyst for providing the dataset and guidance for this project.

## Connect with Me

- **LinkedIn:** [LinkedIn Profile](https://www.linkedin.com/in/bhushan-wanjale/)
