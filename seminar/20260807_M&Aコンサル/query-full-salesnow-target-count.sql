SELECT COUNT(DISTINCT c.corporate_number) AS target_count
FROM data_companies c
LEFT JOIN data_companies_industries dci
  ON dci.corporate_number = c.corporate_number
LEFT JOIN data_industries di
  ON di.id = dci.main_industry_id
WHERE c.contact_form IS NOT NULL
  AND btrim(c.contact_form) <> ''
  AND COALESCE(c.is_contact_sales_ng, false) = false
  AND COALESCE(c.is_contact_info_ng, false) = false
  AND COALESCE(c.is_contact_info_ng_sndb, false) = false
  AND COALESCE(c.contact_ng_flg, 0) = 0
  AND COALESCE(c.bankruptcy_flg, false) = false
  AND COALESCE(c.is_display_ng, false) = false
  AND COALESCE(c.is_display_ng_sndb, false) = false
  AND (
    dci.main_industry_id IN (401, 402, 409)
    OR COALESCE(di.large_industry, '') ~* 'コンサル|専門サービス'
    OR COALESCE(di.small_industry, '') ~* '経営コンサル|戦略コンサル|財務コンサル|M&A|事業承継|事業再生'
    OR COALESCE(c.business_details, '') ~* 'M&A|Ｍ＆Ａ|事業承継|事業再生|企業再生|経営改善|経営コンサル|戦略コンサル|財務コンサル|組織再編|企業価値算定|デューデリジェンス|ファイナンシャル・アドバイザリー|PMI|ポストマージャー'
    OR COALESCE(c.business_description, '') ~* 'M&A|Ｍ＆Ａ|事業承継|事業再生|企業再生|経営改善|経営コンサル|戦略コンサル|財務コンサル|組織再編|企業価値算定|デューデリジェンス|ファイナンシャル・アドバイザリー|PMI|ポストマージャー'
  );
