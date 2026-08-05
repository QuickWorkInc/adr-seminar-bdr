SELECT
  c.corporate_number,
  c.company_name,
  c.company_url,
  c.contact_form,
  c.employee_number,
  c.mail_address,
  c.phone_number,
  c.industry_name,
  c.industry_name2,
  di.large_industry,
  di.small_industry
FROM data_companies c
JOIN data_companies_industries dci
  ON dci.corporate_number = c.corporate_number
JOIN data_industries di
  ON di.id = dci.main_industry_id
WHERE di.large_industry IN (
    '金融', 'IT', 'コンサルティング', '広告・制作',
    '人材・アウトソーシング', '不動産', '製造', '材料・資源',
    'エネルギー', '機械', '商社'
  )
  AND c.employee_number > 3
  AND c.company_url IS NOT NULL
  AND btrim(c.company_url) <> ''
  AND c.contact_form IS NOT NULL
  AND btrim(c.contact_form) <> ''
  AND COALESCE(c.is_contact_sales_ng, false) = false
  AND COALESCE(c.is_contact_info_ng, false) = false
  AND COALESCE(c.is_contact_info_ng_sndb, false) = false
  AND COALESCE(c.contact_ng_flg, 0) = 0
  AND COALESCE(c.bankruptcy_flg, false) = false
  AND COALESCE(c.is_display_ng, false) = false
ORDER BY c.employee_number DESC, c.corporate_number
LIMIT 500;
