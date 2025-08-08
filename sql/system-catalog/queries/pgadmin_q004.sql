    SELECT
	        ca.oid,
	        pg_catalog.concat(pg_catalog.format_type(st.oid,NULL),'->',pg_catalog.format_type(tt.oid,tt.typtypmod)) as name,
	        des.description
	    FROM pg_catalog.pg_cast ca
	    JOIN pg_catalog.pg_type st ON st.oid=castsource
	    JOIN pg_catalog.pg_namespace ns ON ns.oid=st.typnamespace
	    JOIN pg_catalog.pg_type tt ON tt.oid=casttarget
	    JOIN pg_catalog.pg_namespace nt ON nt.oid=tt.typnamespace
	    LEFT JOIN pg_catalog.pg_proc pr ON pr.oid=castfunc
	    LEFT JOIN pg_catalog.pg_namespace np ON np.oid=pr.pronamespace
	    LEFT OUTER JOIN pg_catalog.pg_description des ON (des.objoid=ca.oid AND des.objsubid=0 AND des.classoid='pg_cast'::regclass)
	                                WHERE
	                ca.oid > 16383::OID
	            ORDER BY st.typname, tt.typname
