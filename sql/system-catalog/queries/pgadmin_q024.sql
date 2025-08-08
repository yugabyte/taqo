SELECT
	    c.oid,
	    c.relname AS name,
	    description AS comment
	FROM pg_catalog.pg_class c
	LEFT OUTER JOIN pg_catalog.pg_description des ON (des.objoid=c.oid and des.objsubid=0 AND des.classoid='pg_class'::regclass)
	WHERE
	  c.relkind = 'm'
	    AND c.relnamespace = 'pg_catalog'::regnamespace
	ORDER BY
	    c.relname
