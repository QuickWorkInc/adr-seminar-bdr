SELECT
  c.corporate_number,
  c.company_name,
  c.company_url,
  c.employee_number,
  di.large_industry
FROM data_companies_industries dci
JOIN data_industries di
  ON dci.main_industry_id = di.id
JOIN data_companies c
  ON c.corporate_number = dci.corporate_number
WHERE di.large_industry IN (
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
)
  AND c.company_url IS NOT NULL
  AND btrim(c.company_url) <> ''
  AND c.employee_number IS NOT NULL
ORDER BY c.employee_number DESC NULLS LAST, c.corporate_number
LIMIT 100;
