	SELECT 'session_stats' AS chart_name, pg_catalog.row_to_json(t) AS chart_data
	FROM (SELECT
	   (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog'))) AS "Total",
	   (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = 'active' AND datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog')))  AS "Active",
	   (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = 'idle' AND datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog')))  AS "Idle"
	) t
	UNION ALL
	SELECT 'tps_stats' AS chart_name, pg_catalog.row_to_json(t) AS chart_data
	FROM (SELECT
	   (SELECT sum(xact_commit) + sum(xact_rollback) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog'))) AS "Transactions",
	   (SELECT sum(xact_commit) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog'))) AS "Commits",
	   (SELECT sum(xact_rollback) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog'))) AS "Rollbacks"
	) t
	UNION ALL
	SELECT 'ti_stats' AS chart_name, pg_catalog.row_to_json(t) AS chart_data
	FROM (SELECT
	   (SELECT sum(tup_inserted) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog'))) AS "Inserts",
	   (SELECT sum(tup_updated) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog'))) AS "Updates",
	   (SELECT sum(tup_deleted) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog'))) AS "Deletes"
	) t
	UNION ALL
	SELECT 'to_stats' AS chart_name, pg_catalog.row_to_json(t) AS chart_data
	FROM (SELECT
	   (SELECT sum(tup_fetched) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog'))) AS "Fetched",
	   (SELECT sum(tup_returned) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog'))) AS "Returned"
	) t
	UNION ALL
	SELECT 'bio_stats' AS chart_name, pg_catalog.row_to_json(t) AS chart_data
	FROM (SELECT
	   (SELECT sum(blks_read) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog'))) AS "Reads",
	   (SELECT sum(blks_hit) FROM pg_catalog.pg_stat_database WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = (select oid from pg_database where datname = 'taqo_system_catalog'))) AS "Hits"
	) t
