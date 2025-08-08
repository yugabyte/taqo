SELECT
	    prs.oid, prsname as name, prs.prsnamespace AS schema, des.description
	FROM
	    pg_catalog.pg_ts_parser prs
	    LEFT OUTER JOIN pg_catalog.pg_description des
	ON
	    (
	    des.objoid=prs.oid
	    AND des.classoid='pg_ts_parser'::regclass
	    )
	WHERE
	    prs.prsnamespace = 'pg_catalog'::regnamespace
	ORDER BY name
