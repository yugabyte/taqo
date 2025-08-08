SELECT
	    cfg.oid, cfgname as name, des.description
	FROM
	    pg_catalog.pg_ts_config cfg
	    LEFT OUTER JOIN pg_catalog.pg_description des
	    ON (des.objoid=cfg.oid AND des.classoid='pg_ts_config'::regclass)
	WHERE
	    cfg.cfgnamespace = 'pg_catalog'::regnamespace
	ORDER BY name
