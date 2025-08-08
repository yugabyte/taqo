SELECT c.oid,
	  pg_catalog.quote_ident(n.nspname)||'.'||pg_catalog.quote_ident(c.relname) AS typname
	  FROM pg_catalog.pg_namespace n, pg_catalog.pg_class c
	WHERE c.relkind = 'c' AND c.relnamespace=n.oid
	AND n.nspname NOT LIKE 'pg\_%' AND n.nspname NOT IN ('information_schema')
	ORDER BY typname;
