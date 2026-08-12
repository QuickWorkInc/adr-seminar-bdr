SELECT
  c.corporate_number,
  c.company_name,
  c.company_url,
  c.employee_number,
  c.mail_address,
  c.phone_number,
  di.small_industry
FROM data_companies_industries dci
JOIN data_industries di
  ON dci.main_industry_id = di.id
JOIN data_companies c
  ON c.corporate_number = dci.corporate_number
WHERE di.id = 395
  AND c.company_url IS NOT NULL
  AND btrim(c.company_url) <> ''
  AND c.mail_address IS NOT NULL
  AND btrim(c.mail_address) <> ''
  AND c.mail_address LIKE '%@%'
  AND COALESCE(c.bankruptcy_flg, false) = false
  AND COALESCE(c.is_display_ng, false) = false
ORDER BY c.employee_number DESC NULLS LAST, c.corporate_number
LIMIT 50;
