SELECT id, large_industry, small_industry
FROM data_industries
WHERE large_industry IN ('IT', 'コンサルティング')
   OR small_industry ILIKE '%コンサル%'
ORDER BY large_industry, small_industry
LIMIT 500;
