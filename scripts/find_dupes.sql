SELECT date, source_id, sign_id
FROM scopes
GROUP BY date, source_id, sign_id
HAVING COUNT (*) > 1 
ORDER BY date DESC;