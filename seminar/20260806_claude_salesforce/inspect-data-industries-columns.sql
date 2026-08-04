SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'data_industries'
ORDER BY ordinal_position;
