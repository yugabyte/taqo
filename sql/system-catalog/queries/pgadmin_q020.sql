SELECT
	    pr.oid, pr.proname || '(' || COALESCE(pg_catalog.pg_get_function_identity_arguments(pr.oid), '') || ')' as name,
	    lanname, pg_catalog.pg_get_userbyid(proowner) as funcowner, description
	FROM
	    pg_catalog.pg_proc pr
	JOIN
	    pg_catalog.pg_type typ ON typ.oid=prorettype
	JOIN
	    pg_catalog.pg_language lng ON lng.oid=prolang
	LEFT OUTER JOIN
	    pg_catalog.pg_description des ON (des.objoid=pr.oid AND des.classoid='pg_proc'::regclass)
	WHERE
	   pr.prokind IN ('f', 'w')
	    AND pronamespace = 'pg_catalog'::regnamespace
	    AND typname NOT IN ('trigger', 'event_trigger')
	ORDER BY
	    name;
