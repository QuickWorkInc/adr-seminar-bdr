SELECT COUNT(DISTINCT c.corporate_number) AS target_count
FROM data_companies_industries dci
JOIN data_companies c ON c.corporate_number = dci.corporate_number
WHERE dci.main_industry_id IN (401, 402, 409)
  AND c.contact_form IS NOT NULL
  AND btrim(c.contact_form) <> ''
  AND COALESCE(c.is_contact_sales_ng, false) = false
  AND COALESCE(c.is_contact_info_ng, false) = false
  AND COALESCE(c.is_contact_info_ng_sndb, false) = false
  AND COALESCE(c.contact_ng_flg, 0) = 0
  AND COALESCE(c.bankruptcy_flg, false) = false
  AND COALESCE(c.is_display_ng, false) = false
  AND COALESCE(c.is_display_ng_sndb, false) = false;
