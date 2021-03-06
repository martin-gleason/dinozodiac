COPY(
SELECT scopes.date, signs.dinoname, scopes.scope, sources.url AS website 
FROM scopes, signs, sources
WHERE signs.sign_id = scopes.sign_id AND scopes.source_id = sources.source_id 
ORDER BY date, website)
TO '/Users/marty/Local Dev Projects/dinozodiac/output/dinoscopes.csv';