SELECT DISTINCT ON (c.corporate_number)
  c.corporate_number, c.company_name, c.company_url, c.contact_form,
  c.employee_number, c.phone_number, c.business_details, c.business_description,
  c.is_contact_sales_ng, c.is_contact_info_ng, c.is_contact_info_ng_sndb,
  c.contact_ng_flg, c.bankruptcy_flg, c.is_display_ng
FROM data_companies c
WHERE COALESCE(c.company_url, '') ~* 'nihon-ma|strike.co.jp|ma-cp.com|masouken.com|fundbook.co.jp|jpmas.jp|ondeck.jp|integroup.jp|meinan-ma.com|mabp.co.jp|ma-la.co.jp|jms-support.jp|recof.co.jp|nma.co.jp|rotunda.co.jp|ma-company.co.jp|ma.commercex.co.jp'
ORDER BY c.corporate_number, c.employee_number DESC NULLS LAST;
