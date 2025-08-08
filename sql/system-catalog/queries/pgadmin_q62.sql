SELECT c.relchecks, c.relkind, c.relhasindex, c.relhasrules, c.relhastriggers, c.relrowsecurity, c.relforcerowsecurity, c.relispartition, '', c.reltablespace, CASE WHEN c.reloftype = 0 THEN '' ELSE c.reloftype::pg_catalog.regtype::pg_catalog.text END, c.relpersistence, c.relreplident
	FROM pg_catalog.pg_class c
	 LEFT JOIN pg_catalog.pg_class tc ON (c.reltoastrelid = tc.oid)
	WHERE c.oid = 'pg_statistic'::regclass;
