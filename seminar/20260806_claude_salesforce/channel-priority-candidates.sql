WITH candidates AS (
  SELECT *
  FROM data_companies
  WHERE (
      (mail_address IS NOT NULL AND btrim(mail_address) <> '' AND mail_address LIKE '%@%')
      OR (contact_form IS NOT NULL AND btrim(contact_form) <> '')
    )
    AND COALESCE(is_contact_sales_ng, false) = false
    AND COALESCE(is_contact_info_ng, false) = false
    AND COALESCE(is_contact_info_ng_sndb, false) = false
    AND COALESCE(contact_ng_flg, 0) = 0
    AND COALESCE(bankruptcy_flg, false) = false
    AND COALESCE(is_display_ng, false) = false
    AND employee_number IS NOT NULL
  ORDER BY employee_number DESC, corporate_number
  LIMIT 5000
)
SELECT DISTINCT ON (c.corporate_number)
  c.corporate_number,
  c.company_name,
  c.company_url,
  c.employee_number,
  c.mail_address,
  c.contact_form,
  c.phone_number,
  c.industry_name,
  c.industry_name2,
  di.large_industry,
  di.small_industry
FROM candidates c
JOIN data_companies_industries dci
  ON dci.corporate_number = c.corporate_number
JOIN data_industries di
  ON di.id = dci.main_industry_id
WHERE di.large_industry IN (
  '金融', 'IT', 'コンサルティング', '広告・制作',
  '人材・アウトソーシング', '不動産', '製造', '材料・資源',
  'エネルギー', '機械', '商社'
)
ORDER BY c.corporate_number, c.employee_number DESC NULLS LAST;
