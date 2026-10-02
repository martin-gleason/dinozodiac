-- Export every horoscope with its dinosaur and website to CSV.
-- Run from the project root with psql (\copy writes on *your* machine, unlike COPY):
--   psql -d dinozodiac -f sql/export_dinoscopes.sql
\copy (SELECT scopes.date, signs.dinoname, scopes.scope, sources.url AS website FROM scopes JOIN signs USING (sign_id) JOIN sources USING (source_id) ORDER BY date, website) TO 'output/dinoscopes.csv' WITH (FORMAT csv, HEADER)
