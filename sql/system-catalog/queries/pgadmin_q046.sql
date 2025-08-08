SELECT ct.oid,
	    conname as name,
	    NOT convalidated as convalidated,
	    description as comment
	FROM pg_catalog.pg_constraint ct
	LEFT OUTER JOIN pg_catalog.pg_description des ON (des.objoid=ct.oid AND des.classoid='pg_constraint'::regclass)
	WHERE contype='f' AND
	    conrelid = 'table123'::regclass
	ORDER BY conname
