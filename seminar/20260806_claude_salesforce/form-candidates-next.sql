WITH candidates AS (
  SELECT
    corporate_number,
    company_name,
    company_url,
    contact_form,
    employee_number,
    phone_number,
    postal_code,
    prefecture,
    city,
    address,
    business_details,
    business_description
  FROM data_companies
  WHERE company_url IS NOT NULL
    AND btrim(company_url) <> ''
    AND contact_form IS NOT NULL
    AND btrim(contact_form) <> ''
    AND (mail_address IS NULL OR btrim(mail_address) = '')
    AND COALESCE(is_contact_sales_ng, false) = false
    AND COALESCE(is_contact_info_ng, false) = false
    AND COALESCE(is_contact_info_ng_sndb, false) = false
    AND COALESCE(contact_ng_flg, 0) = 0
    AND COALESCE(bankruptcy_flg, false) = false
    AND COALESCE(is_display_ng, false) = false
    AND employee_number IS NOT NULL
  ORDER BY employee_number DESC, corporate_number
  LIMIT 3000
)
SELECT DISTINCT ON (c.corporate_number)
  c.corporate_number,
  c.company_name,
  c.company_url,
  c.contact_form,
  c.employee_number,
  c.phone_number,
  c.postal_code,
  c.prefecture,
  c.city,
  c.address,
  c.business_details,
  c.business_description,
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
ORDER BY c.corporate_number, c.employee_number DESC;
