	SELECT
	    pid,
	    datname,
	    usename,
	    application_name,
	    client_addr,
	    pg_catalog.to_char(backend_start, 'YYYY-MM-DD HH24:MI:SS TZ') AS backend_start,
	    state,
	    wait_event_type || ': ' || wait_event AS wait_event,
	    array_to_string(pg_catalog.pg_blocking_pids(pid), ', ') AS blocking_pids,
	    query,
	    pg_catalog.to_char(state_change, 'YYYY-MM-DD HH24:MI:SS TZ') AS state_change,
	    pg_catalog.to_char(query_start, 'YYYY-MM-DD HH24:MI:SS TZ') AS query_start,
	    pg_catalog.to_char(xact_start, 'YYYY-MM-DD HH24:MI:SS TZ') AS xact_start,
	    backend_type,
	    CASE WHEN state = 'active' THEN ROUND((extract(epoch from now() - query_start) / 60)::numeric, 2) ELSE 0 END AS active_since
	FROM
	    pg_catalog.pg_stat_activity
	WHERE
	    datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog'))ORDER BY pid
