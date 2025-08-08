SELECT
	    dict.oid, dictname as name,
	    dictnamespace as schema,
	    des.description
	FROM
	    pg_catalog.pg_ts_dict dict
	    LEFT OUTER JOIN pg_catalog.pg_description des ON (des.objoid=dict.oid AND des.classoid='pg_ts_dict'::regclass)
	WHERE
	    dict.dictnamespace = 'pg_catalog'::regnamespace
	ORDER BY name
