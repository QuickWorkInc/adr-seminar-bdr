SELECT DISTINCT ON (c.corporate_number)
  c.corporate_number,
  c.company_name,
  c.company_url,
  c.contact_form,
  c.employee_number,
  c.business_details,
  c.business_description,
  di.large_industry,
  di.small_industry
FROM data_companies_industries dci
JOIN data_companies c ON c.corporate_number = dci.corporate_number
JOIN data_industries di ON di.id = dci.main_industry_id
WHERE dci.main_industry_id IN (401, 402, 409)
  AND c.company_url IS NOT NULL AND btrim(c.company_url) <> ''
  AND c.contact_form IS NOT NULL AND btrim(c.contact_form) <> ''
  AND COALESCE(c.is_contact_sales_ng, false) = false
  AND COALESCE(c.is_contact_info_ng, false) = false
  AND COALESCE(c.is_contact_info_ng_sndb, false) = false
  AND COALESCE(c.contact_ng_flg, 0) = 0
  AND COALESCE(c.bankruptcy_flg, false) = false
  AND COALESCE(c.is_display_ng, false) = false
  AND COALESCE(c.employee_number, 0) >= 10
ORDER BY c.corporate_number, c.employee_number DESC NULLS LAST
LIMIT 120;
