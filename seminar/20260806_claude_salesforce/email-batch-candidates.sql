WITH candidates AS (
  SELECT
    corporate_number,
    company_name,
    company_url,
    employee_number,
    mail_address,
    phone_number
  FROM data_companies
  WHERE company_url IS NOT NULL
    AND btrim(company_url) <> ''
    AND mail_address IS NOT NULL
    AND btrim(mail_address) <> ''
    AND mail_address LIKE '%@%'
    AND COALESCE(bankruptcy_flg, false) = false
    AND COALESCE(is_display_ng, false) = false
  ORDER BY employee_number DESC NULLS LAST, corporate_number
  LIMIT 3000
)
SELECT DISTINCT ON (c.corporate_number)
  c.corporate_number,
  c.company_name,
  c.company_url,
  c.employee_number,
  c.mail_address,
  c.phone_number,
  di.large_industry
FROM candidates c
JOIN data_companies_industries dci
  ON dci.corporate_number = c.corporate_number
JOIN data_industries di
  ON di.id = dci.main_industry_id
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
ORDER BY c.corporate_number, c.employee_number DESC NULLS LAST;
