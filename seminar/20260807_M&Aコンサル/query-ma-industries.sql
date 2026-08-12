SELECT id, large_industry, small_industry
FROM data_industries
WHERE large_industry ILIKE '%M&A%'
   OR small_industry ILIKE '%M&A%'
   OR small_industry ILIKE '%仲介%'
   OR small_industry ILIKE '%事業承継%'
ORDER BY large_industry, small_industry;
