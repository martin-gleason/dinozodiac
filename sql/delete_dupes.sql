SELECT scopes.scope_id, s
FROM scopes

RIGHT JOIN (

	SELECT date, source_id, sign_id, count (date)
	FROM scopes AS dupes
	GROUP BY date, source_id, sign_id	
	HAVING count(date) > 1
	) as dupes
	
ON scopes.date = dupes.date AND 
scopes.source_id = dupes.source_id AND 
scopes.sign_id = dupes.sign_id
group by scope_id;