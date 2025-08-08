SELECT cl.oid as oid, relname as name, relnamespace as schema, description as comment
	FROM pg_catalog.pg_class cl
	LEFT OUTER JOIN pg_catalog.pg_description des ON (des.objoid=cl.oid
	    AND des.classoid='pg_class'::regclass)
	WHERE
	    relkind = 'S'
	    AND relnamespace = 'pg_catalog'::regnamespace
	ORDER BY relname
