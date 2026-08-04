WITH target_industries AS (
  SELECT unnest(ARRAY[
    '金融',
    'IT',
    'コンサルティング',
    '広告・制作',
    '人材・アウトソーシング',
    '不動産',
    '製造',
    '材料・資源',
    'エネルギー',
    '機械',
    '商社'
  ]) AS large_industry
), base AS (
  SELECT DISTINCT
    c.corporate_number,
    di.large_industry,
    c.company_url
  FROM data_companies c
  JOIN data_companies_industries dci
    ON c.corporate_number = dci.corporate_number
  JOIN data_industries di
    ON dci.main_industry_id = di.id
  JOIN target_industries ti
    ON di.large_industry = ti.large_industry
  WHERE c.corporate_number IS NOT NULL
)
SELECT
  large_industry,
  COUNT(DISTINCT corporate_number) AS all_companies,
  COUNT(DISTINCT corporate_number) FILTER (
    WHERE company_url IS NOT NULL AND btrim(company_url) <> ''
  ) AS companies_with_website
FROM base
GROUP BY large_industry

UNION ALL

SELECT
  '合計（法人番号重複排除）' AS large_industry,
  COUNT(DISTINCT corporate_number) AS all_companies,
  COUNT(DISTINCT corporate_number) FILTER (
    WHERE company_url IS NOT NULL AND btrim(company_url) <> ''
  ) AS companies_with_website
FROM base
ORDER BY large_industry;
