SELECT e.oid, e.evtname AS name,
	    pg_catalog.obj_description(e.oid, 'pg_event_trigger') AS comment
	FROM pg_catalog.pg_event_trigger e
	ORDER BY e.evtname
