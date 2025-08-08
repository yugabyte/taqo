SELECT
	    nsp.oid,
	    nsp.nspname as name,
	    pg_catalog.has_schema_privilege(nsp.oid, 'CREATE') as can_create,
	    pg_catalog.has_schema_privilege(nsp.oid, 'USAGE') as has_usage,
	    des.description
	FROM
	    pg_catalog.pg_namespace nsp
	    LEFT OUTER JOIN pg_catalog.pg_description des ON
	        (des.objoid=nsp.oid AND des.classoid='pg_namespace'::regclass)
	WHERE
	             nspname NOT LIKE E'pg\\_%' AND
	            NOT (
	(nsp.nspname = 'pg_catalog' AND EXISTS
	        (SELECT 1 FROM pg_catalog.pg_class WHERE relname = 'pg_class' AND
	            relnamespace = nsp.oid LIMIT 1)) OR
	    (nsp.nspname = 'pgagent' AND EXISTS
	        (SELECT 1 FROM pg_catalog.pg_class WHERE relname = 'pga_job' AND
	            relnamespace = nsp.oid LIMIT 1)) OR
	    (nsp.nspname = 'information_schema' AND EXISTS
	        (SELECT 1 FROM pg_catalog.pg_class WHERE relname = 'tables' AND
	            relnamespace = nsp.oid LIMIT 1))
	    )
	ORDER BY nspname;
