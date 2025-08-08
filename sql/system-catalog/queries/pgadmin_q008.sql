SELECT
	    nsp.nspname as schema_name,
	    (nsp.nspname = 'pg_catalog' AND EXISTS
	        (SELECT 1 FROM pg_catalog.pg_class WHERE relname = 'pg_class' AND
	            relnamespace = nsp.oid LIMIT 1)) OR
	    (nsp.nspname = 'pgagent' AND EXISTS
	        (SELECT 1 FROM pg_catalog.pg_class WHERE relname = 'pga_job' AND
	            relnamespace = nsp.oid LIMIT 1)) OR
	    (nsp.nspname = 'information_schema' AND EXISTS
	        (SELECT 1 FROM pg_catalog.pg_class WHERE relname = 'tables' AND
	            relnamespace = nsp.oid LIMIT 1)) AS is_catalog,
	    CASE
	    WHEN nsp.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END AS db_support
	FROM
	    pg_catalog.pg_namespace nsp
	WHERE
	    nsp.oid = 'information_schema'::regnamespace;
