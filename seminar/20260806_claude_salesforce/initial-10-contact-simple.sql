SELECT
  corporate_number,
  company_name,
  company_url,
  employee_number,
  mail_address,
  phone_number,
  bankruptcy_flg,
  is_display_ng
FROM data_companies
WHERE corporate_number IN (
  8010001076758,
  4010001032038,
  3120005007273,
  8010005007932,
  1010001174683,
  5120005007271,
  5020001016039,
  7010401047319,
  3011001041302,
  1010001067359
)
ORDER BY employee_number DESC;
