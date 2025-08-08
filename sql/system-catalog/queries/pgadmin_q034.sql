SELECT
	    ts.oid AS oid, spcname AS name, spcowner as owner,
	    pg_catalog.shobj_description(oid, 'pg_tablespace') AS description
	FROM
	    pg_catalog.pg_tablespace ts
	ORDER BY name;
