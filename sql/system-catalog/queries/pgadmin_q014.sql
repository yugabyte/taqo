SELECT
	    d.oid, d.typname as name, pg_catalog.pg_get_userbyid(d.typowner) as owner,
	    bn.nspname as basensp, des.description
	FROM
	    pg_catalog.pg_type d
	JOIN
	    pg_catalog.pg_type b ON b.oid = d.typbasetype
	JOIN
	    pg_catalog.pg_namespace bn ON bn.oid=d.typnamespace
	LEFT OUTER JOIN
	    pg_catalog.pg_description des ON (des.objoid=d.oid AND des.classoid='pg_type'::regclass)
	WHERE
	    d.typnamespace = 'pg_catalog'::regnamespace
	ORDER BY
	    d.typname;
