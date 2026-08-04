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
LIMIT 1000;
