SELECT c.oid, c.collname AS name, des.description
	FROM pg_catalog.pg_collation c
	    LEFT OUTER JOIN pg_catalog.pg_description des ON (des.objoid=c.oid AND des.classoid='pg_collation'::regclass)
	WHERE c.collnamespace = 'pg_catalog'::regnamespace
	ORDER BY c.collname, c.oid;
