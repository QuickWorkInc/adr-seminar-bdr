SELECT DISTINCT ON (c.corporate_number)
  c.corporate_number,
  c.company_name,
  c.company_url,
  c.contact_form,
  c.employee_number,
  c.phone_number,
  c.prefecture,
  c.city,
  c.business_details,
  c.business_description,
  c.is_contact_sales_ng,
  c.is_contact_info_ng,
  c.is_contact_info_ng_sndb,
  c.contact_ng_flg,
  c.bankruptcy_flg,
  c.is_display_ng,
  di.large_industry,
  di.small_industry
FROM data_companies c
LEFT JOIN data_companies_industries dci
  ON dci.corporate_number = c.corporate_number
LEFT JOIN data_industries di
  ON di.id = dci.main_industry_id
WHERE c.company_name IN (
  '株式会社日本M&Aセンター',
  '株式会社ストライク',
  'M&Aキャピタルパートナーズ株式会社',
  '株式会社M&A総合研究所',
  '株式会社fundbook',
  'ジャパンM&Aソリューション株式会社',
  '株式会社オンデック',
  'インテグループ株式会社',
  '名南M&A株式会社',
  '株式会社M&Aベストパートナーズ',
  'M&Aロイヤルアドバイザリー株式会社',
  '株式会社経営承継支援',
  '株式会社レコフ',
  '日本M&A株式会社',
  'ロタンダコンサルティング株式会社',
  '株式会社M&Aカンパニー',
  'CommerceX M&A株式会社'
)
ORDER BY c.corporate_number, c.employee_number DESC NULLS LAST;
