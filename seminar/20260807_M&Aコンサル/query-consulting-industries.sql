SELECT id, large_industry, small_industry
FROM data_industries
WHERE large_industry ILIKE '%コンサル%'
   OR small_industry ILIKE '%コンサル%'
   OR small_industry ILIKE '%事業承継%'
   OR small_industry ILIKE '%M&A%'
ORDER BY large_industry, small_industry;
