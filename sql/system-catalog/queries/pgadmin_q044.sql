SELECT
	    *
	FROM
	    (SELECT
	        pg_catalog.format_type(t.oid,NULL) AS typname,
	        CASE WHEN typelem > 0 THEN typelem ELSE t.oid END as elemoid,
	        typlen, typtype, t.oid, nspname,
	        (SELECT COUNT(1) FROM pg_catalog.pg_type t2 WHERE t2.typname = t.typname) > 1 AS isdup,
	        CASE WHEN t.typcollation != 0 THEN TRUE ELSE FALSE END AS is_collatable
	    FROM
	        pg_catalog.pg_type t
	    JOIN
	        pg_catalog.pg_namespace nsp ON typnamespace=nsp.oid
	    WHERE
	        (NOT (typname = 'unknown' AND nspname = 'pg_catalog'))
	    AND
	        typisdefined AND typtype IN ('b', 'c', 'd', 'e', 'r', 'm')
	AND NOT EXISTS (SELECT 1 FROM pg_catalog.pg_class WHERE relnamespace=typnamespace
	AND relname = typname AND relkind != 'c') AND
	(typname NOT LIKE '_%' OR NOT EXISTS (SELECT 1 FROM pg_catalog.pg_class WHERE
	relnamespace=typnamespace AND relname = substring(typname FROM 2)::name
	AND relkind != 'c'))
	AND nsp.nspname != 'information_schema'
	    UNION SELECT 'smallserial', 0, 2, 'b', 0, 'pg_catalog', false, false
	    UNION SELECT 'bigserial', 0, 8, 'b', 0, 'pg_catalog', false, false
	    UNION SELECT 'serial', 0, 4, 'b', 0, 'pg_catalog', false, false
	    ) AS dummy
	ORDER BY nspname <> 'pg_catalog', nspname <> 'public', nspname, 1
