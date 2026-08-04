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
  business_description,
  is_contact_sales_ng,
  is_contact_info_ng,
  is_contact_info_ng_sndb,
  contact_ng_flg
FROM data_companies
WHERE corporate_number IN (
  8010401050387,
  3010001008848,
  6010801003186,
  4130001000049,
  2010401044997,
  6120001059662,
  1120001037978,
  1010001008668,
  6010001146760,
  1010401010455,
  8010501050089,
  7130001037872,
  7010601022674,
  6140001005714,
  5120001077450,
  9120001079055,
  4130001030475
)
ORDER BY employee_number DESC;
