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
  di.large_industry,
  di.small_industry,
  c.is_contact_sales_ng,
  c.is_contact_info_ng,
  c.is_contact_info_ng_sndb,
  c.contact_ng_flg
FROM data_companies c
LEFT JOIN data_companies_industries dci
  ON dci.corporate_number = c.corporate_number
LEFT JOIN data_industries di
  ON di.id = dci.main_industry_id
WHERE c.company_url IS NOT NULL
  AND btrim(c.company_url) <> ''
  AND c.contact_form IS NOT NULL
  AND btrim(c.contact_form) <> ''
  AND COALESCE(c.is_contact_sales_ng, false) = false
  AND COALESCE(c.is_contact_info_ng, false) = false
  AND COALESCE(c.is_contact_info_ng_sndb, false) = false
  AND COALESCE(c.contact_ng_flg, 0) = 0
  AND COALESCE(c.bankruptcy_flg, false) = false
  AND COALESCE(c.is_display_ng, false) = false
  AND COALESCE(c.employee_number, 0) >= 10
  AND (
    COALESCE(di.large_industry, '') ~* '経営コンサル|コンサルティング|専門サービス'
    OR COALESCE(di.small_industry, '') ~* '経営コンサル|M&A|事業承継|財務コンサル|戦略コンサル'
  )
  AND (
    COALESCE(c.business_details, '') ~* 'M&A|Ｍ＆Ａ|事業承継|企業再生|FA|ファイナンシャル・アドバイザリー|デューデリジェンス|PMI'
    OR COALESCE(c.business_description, '') ~* 'M&A|Ｍ＆Ａ|事業承継|企業再生|FA|ファイナンシャル・アドバイザリー|デューデリジェンス|PMI'
  )
  AND c.company_name NOT IN (
    'M&Aロイヤルアドバイザリー株式会社',
    '株式会社オンデック',
    '株式会社M&A総合研究所',
    '株式会社日本M&Aセンター',
    'アドバイザリー株式会社',
    '株式会社J-TAPアドバイザリー',
    '名南M&A株式会社'
  )
ORDER BY c.corporate_number, c.employee_number DESC NULLS LAST
LIMIT 100;
