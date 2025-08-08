SELECT
	    CASE WHEN c.relkind = 'p' THEN True ELSE False END As ptable
	FROM
	    pg_catalog.pg_class c
	WHERE
	    c.oid = 'table123'::regclass
