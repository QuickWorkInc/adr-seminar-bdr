SELECT DISTINCT ON (c.corporate_number)
  c.corporate_number, c.company_name, c.company_url, c.contact_form,
  c.employee_number, c.business_details, c.business_description,
  c.is_contact_sales_ng, c.is_contact_info_ng, c.is_contact_info_ng_sndb,
  c.contact_ng_flg, c.bankruptcy_flg, c.is_display_ng
FROM data_companies c
WHERE c.company_name ILIKE '%M&Aエグゼクティブパートナーズ%'
   OR c.company_name ILIKE '%M&Aプライムグループ%'
   OR c.company_name ILIKE '%M&A共創パートナーズ%'
   OR c.company_name ILIKE '%M&Aグローバルキャピタル%'
   OR c.company_name ILIKE '%M&A承継機構%'
   OR c.company_name ILIKE '%M&Aディレクションズ%'
   OR c.company_name ILIKE '%M&Aフォース%'
   OR c.company_name ILIKE '%M&Aクラウド%'
   OR c.company_name ILIKE '%CINC Capital%'
   OR c.company_name ILIKE '%NEWOLD CAPITAL%'
ORDER BY c.corporate_number, c.employee_number DESC NULLS LAST;
