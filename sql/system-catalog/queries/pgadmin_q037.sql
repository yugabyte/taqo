SELECT fdw.oid, fdwname as name, fdwhandler, fdwvalidator, description,
	    fdwoptions AS fdwoptions, pg_catalog.pg_get_userbyid(fdwowner) as fdwowner, pg_catalog.array_to_string(fdwacl::text[], ', ') as acl,
	    CASE
	    -- EPAS in redwood mode, concatenation of a string with NULL results as the original string
	    WHEN vp.proname IS NULL THEN NULL
	    ELSE pg_catalog.quote_ident(vp_nsp.nspname)||'.'||pg_catalog.quote_ident(vp.proname)
	    END fdwvalue,
	    CASE
	    -- EPAS in redwood mode, concatenation of a string with NULL results as the original string
	    WHEN vh.proname IS NULL THEN NULL
	    ELSE pg_catalog.quote_ident(vh_nsp.nspname)||'.'||pg_catalog.quote_ident(vh.proname)
	    END fdwhan
	FROM pg_catalog.pg_foreign_data_wrapper fdw
	    LEFT OUTER JOIN pg_catalog.pg_proc vh on vh.oid=fdwhandler
	    LEFT OUTER JOIN pg_catalog.pg_proc vp on vp.oid=fdwvalidator
	    LEFT OUTER JOIN pg_catalog.pg_namespace vh_nsp ON vh_nsp.oid=vh.pronamespace
	    LEFT OUTER JOIN pg_catalog.pg_namespace vp_nsp ON vp_nsp.oid=vp.pronamespace
	    LEFT OUTER JOIN pg_catalog.pg_description des ON (des.objoid=fdw.oid AND des.objsubid=0 AND des.classoid='pg_foreign_data_wrapper'::regclass)
	ORDER BY fdwname
