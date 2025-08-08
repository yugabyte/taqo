SELECT
	    tmpl.oid, tmplname as name, tmpl.tmplnamespace AS schema, des.description
	FROM
	    pg_catalog.pg_ts_template tmpl
	    LEFT OUTER JOIN pg_catalog.pg_description des
	ON
	    (
	    des.objoid=tmpl.oid
	    AND des.classoid='pg_ts_template'::regclass
	    )
	WHERE
	    tmpl.tmplnamespace = 'pg_catalog'::regnamespace
	ORDER BY name
