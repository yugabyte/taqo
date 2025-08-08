SELECT
	    x.oid, pg_catalog.pg_get_userbyid(extowner) AS owner,
	    x.extname AS name, n.nspname AS schema,
	    x.extrelocatable AS relocatable, x.extversion AS version,
	    e.comment
	FROM
	    pg_catalog.pg_extension x
	    LEFT JOIN pg_catalog.pg_namespace n ON x.extnamespace=n.oid
	    JOIN pg_catalog.pg_available_extensions() e(name, default_version, comment) ON x.extname=e.name ORDER BY x.extname
