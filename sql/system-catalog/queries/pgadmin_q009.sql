SELECT
	    c.oid, c.relname as name, description
	FROM
	    pg_catalog.pg_class c
	    LEFT OUTER JOIN pg_catalog.pg_description d
	        ON d.objoid=c.oid AND d.classoid='pg_class'::regclass
	WHERE relnamespace = 'information_schema'::regnamespace
	ORDER BY relname;
