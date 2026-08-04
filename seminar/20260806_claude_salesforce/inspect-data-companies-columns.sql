SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'data_companies'
ORDER BY ordinal_position;
