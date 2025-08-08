SELECT obj_type, obj_name,
	    pg_catalog.REPLACE(obj_path, '/'||sn.schema_name||'/', '/'||CASE sn.schema_name
	    WHEN 'pg_catalog' THEN 'PostgreSQL Catalog (pg_catalog)'
	    WHEN 'pgagent' THEN 'pgAgent Job Scheduler (pgagent)'
	    WHEN 'information_schema' THEN 'ANSI (information_schema)'
	    ELSE sn.schema_name
	    END||'/') AS obj_path,
	    schema_name, show_node, other_info,
	    CASE
	        WHEN sn.schema_name IN ('pg_catalog', 'pgagent', 'information_schema') THEN
	            CASE WHEN CASE
	    WHEN sn.schema_name = ANY('{information_schema}')
	        THEN false
	    ELSE true END THEN 'D' ELSE 'O' END
	        ELSE 'N'
	    END AS catalog_level
	FROM (
	    SELECT
	    CASE
	        WHEN c.relkind = 'S' THEN 'sequence'
	        WHEN c.relkind = 'v' THEN 'view'
	        WHEN c.relkind = 'm' THEN 'mview'
	        ELSE 'should not happen'
	    END::text AS obj_type, c.relname AS obj_name,
	    ':schema.'|| n.oid || ':/' || n.nspname || '/' ||
	    CASE
	        WHEN c.relkind = 'S' THEN ':sequence.'
	        WHEN c.relkind = 'v' THEN ':view.'
	        WHEN c.relkind = 'm' THEN ':mview.'
	        ELSE 'should not happen'
	    END || c.oid ||':/' || c.relname AS obj_path, n.nspname AS schema_name,
	    CASE
	        WHEN c.relkind = 'S' THEN True
	        WHEN c.relkind = 'v' THEN True
	        WHEN c.relkind = 'm' THEN True
	        ELSE False
	    END AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_class c
	    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
	        WHERE c.relkind in ('S','v','m')
	        AND CASE WHEN c.relkind in ('S', 'm') THEN CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END ELSE true END
	    UNION
	    SELECT CASE WHEN c.relispartition THEN 'partition' ELSE 'table' END::text AS obj_type, c.relname AS obj_name,
	    ':schema.'|| n.oid || ':/' || n.nspname || '/' || (
			WITH RECURSIVE table_path_data as (
				select c.oid as oid, 0 as height, c.relkind,
					CASE c.relispartition WHEN true THEN ':partition.' ELSE ':table.' END || c.oid || ':/' || c.relname as path
				union
				select rel.oid, pt.height+1 as height, rel.relkind,
					CASE rel.relispartition WHEN true THEN ':partition.' ELSE ':table.' END
					|| rel.oid || ':/' || rel.relname || '/' || pt.path as path
				from pg_catalog.pg_class rel JOIN pg_catalog.pg_namespace nsp ON rel.relnamespace = nsp.oid
				join pg_catalog.pg_inherits inh ON inh.inhparent = rel.oid
				join table_path_data pt ON inh.inhrelid = pt.oid
			)
			select CASE WHEN relkind = 'p' THEN path ELSE ':table.' || c.oid || ':/' || c.relname END AS path
			from table_path_data order by height desc limit 1
		) obj_path, n.nspname AS schema_name,
		CASE WHEN c.relispartition THEN True
		    ELSE True END AS show_node,
	    NULL AS other_info
	    FROM pg_catalog.pg_class c
	    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
	    WHERE c.relkind in ('p','r','t')
	        AND CASE WHEN c.relispartition THEN CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END ELSE true END
	    UNION
	    SELECT 'index'::text AS obj_type, cls.relname AS obj_name, ':schema.'|| n.oid || ':/' || n.nspname || '/' ||
	        case
	            when tab.relkind = 'm' then ':mview.' || tab.oid || ':' || '/' || tab.relname
	            WHEN tab.relkind in ('r', 't', 'p') THEN
	                (
	                    WITH RECURSIVE table_path_data as (
	                        select tab.oid as oid, 0 as height, tab.relkind,
	                            CASE tab.relispartition WHEN true THEN ':partition.' ELSE ':table.' END || tab.oid || ':/' || tab.relname as path
	                        union
	                        select rel.oid, pt.height+1 as height, rel.relkind,
	                            CASE rel.relispartition WHEN true THEN ':partition.' ELSE ':table.' END
	                            || rel.oid || ':/' || rel.relname || '/' || pt.path as path
	                        from pg_catalog.pg_class rel JOIN pg_catalog.pg_namespace nsp ON rel.relnamespace = nsp.oid
	                        join pg_catalog.pg_inherits inh ON inh.inhparent = rel.oid
	                        join table_path_data pt ON inh.inhrelid = pt.oid
	                    )
	                    select CASE WHEN relkind = 'p' THEN path ELSE ':table.' || tab.oid || ':/' || tab.relname END AS path
	                    from table_path_data order by height desc limit 1
	               )
	        end
	        || '/:index.'|| cls.oid ||':/' || cls.relname AS obj_path, n.nspname AS schema_name,
	    True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_index idx
	    JOIN pg_catalog.pg_class cls ON cls.oid=indexrelid
	    JOIN pg_catalog.pg_class tab ON tab.oid=indrelid
	    JOIN pg_catalog.pg_namespace n ON n.oid=tab.relnamespace
	    LEFT JOIN pg_catalog.pg_depend dep ON (dep.classid = cls.tableoid AND dep.objid = cls.oid AND dep.refobjsubid = '0' AND dep.refclassid=(SELECT oid FROM pg_catalog.pg_class WHERE relname='pg_constraint') AND dep.deptype='i')
	    LEFT OUTER JOIN pg_catalog.pg_constraint con ON (con.tableoid = dep.refclassid AND con.oid = dep.refobjid)
	    LEFT OUTER JOIN pg_catalog.pg_description des ON des.objoid=cls.oid
	    LEFT OUTER JOIN pg_catalog.pg_description desp ON (desp.objoid=con.oid AND desp.objsubid = 0)
	    WHERE contype IS NULL
	    AND CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    SELECT
	        CASE
	            WHEN t.typname IN ('trigger', 'event_trigger') THEN 'trigger_function'
	            WHEN p.prokind = 'p' THEN 'procedure'
	            ELSE 'function'
	        END::text AS obj_type, p.proname AS obj_name,
	        ':schema.'|| n.oid || ':/' || n.nspname || '/' ||
	        CASE
	            WHEN t.typname IN ('trigger', 'event_trigger') THEN ':trigger_function.'
	            WHEN p.prokind = 'p' THEN ':procedure.'
	            ELSE ':function.'
	        END || p.oid ||':/' || p.proname AS obj_path, n.nspname AS schema_name,
	        CASE
	            WHEN t.typname IN ('trigger', 'event_trigger') THEN True
	            WHEN p.prokind = 'p' THEN True
	            ELSE True
	        END AS show_node,
	        pg_catalog.pg_get_function_identity_arguments(p.oid) AS other_info
	    from pg_catalog.pg_proc p join pg_catalog.pg_namespace n
	    on p.pronamespace = n.oid join pg_catalog.pg_type t
	    on p.prorettype = t.oid join pg_catalog.pg_language lng
	    ON lng.oid=p.prolang
	    WHERE p.prokind IN ('f', 'w', 'p')
	    AND CASE
	        WHEN t.typname IN ('trigger', 'event_trigger') THEN lng.lanname NOT IN ('edbspl', 'sql', 'internal')
	        ELSE true
	        END
	    AND (CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END) AND p.prokind != 'a'
	    UNION
	    select 'event_trigger'::text AS obj_type, evtname AS obj_name, ':event_trigger.'||oid||':/' || evtname AS obj_path, ''::text AS schema_name,
	    True AS show_node, NULL AS other_info from pg_catalog.pg_event_trigger
	    UNION
	    select 'schema'::text AS obj_type, n.nspname AS obj_name,
	    ':schema.'||n.oid||':/' || n.nspname as obj_path, n.nspname AS schema_name,
	    True AS show_node, NULL AS other_info from pg_catalog.pg_namespace n
	    where CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    select 'column'::text AS obj_type, a.attname AS obj_name,
	    ':schema.'||n.oid||':/' || n.nspname || '/' ||
	    case
	        WHEN t.relkind in ('r', 't', 'p') THEN ':table.'
	        WHEN t.relkind = 'v' THEN ':view.'
	        WHEN t.relkind = 'm' THEN ':mview.'
	        else 'should not happen'
	    end || t.oid || ':/' || t.relname || '/:column.'|| a.attnum ||':/' || a.attname AS obj_path, n.nspname AS schema_name,
	    True AS show_node, NULL AS other_info
	    from pg_catalog.pg_attribute a
	    inner join pg_catalog.pg_class t on a.attrelid = t.oid and t.relkind in ('r','t','p','v','m')
	    left join pg_catalog.pg_namespace n on t.relnamespace = n.oid where a.attnum > 0
	    and not t.relispartition
	    UNION
	    SELECT
	    CASE
	        WHEN c.contype = 'c' THEN  'check_constraint'
	        WHEN c.contype = 'f' THEN  'foreign_key'
	        WHEN c.contype = 'p' THEN  'primary_key'
	        WHEN c.contype = 'u' THEN  'unique_constraint'
	        WHEN c.contype = 'x' THEN  'exclusion_constraint'
	    END::text AS obj_type,
	    case when tf.relname is null then c.conname else c.conname || ' -> ' || tf.relname end AS obj_name,
	    ':schema.'||n.oid||':/' || n.nspname||'/'||
	    (
			WITH RECURSIVE table_path_data as (
				select t.oid as oid, 0 as height, t.relkind,
					CASE t.relispartition WHEN true THEN ':partition.' ELSE ':table.' END || t.oid || ':/' || t.relname as path
				union
				select rel.oid, pt.height+1 as height, rel.relkind,
					CASE rel.relispartition WHEN true THEN ':partition.' ELSE ':table.' END
					|| rel.oid || ':/' || rel.relname || '/' || pt.path as path
				from pg_catalog.pg_class rel JOIN pg_catalog.pg_namespace nsp ON rel.relnamespace = nsp.oid
				join pg_catalog.pg_inherits inh ON inh.inhparent = rel.oid
				join table_path_data pt ON inh.inhrelid = pt.oid
			)
			select CASE WHEN relkind = 'p' THEN path ELSE ':table.' || t.oid || ':/' || t.relname END AS path
			from table_path_data order by height desc limit 1
		) ||
	    CASE
	        WHEN c.contype = 'c' THEN  '/:check_constraint.' ||c.oid
	        WHEN c.contype = 'f' THEN  '/:foreign_key.' ||c.oid
	        WHEN c.contype = 'p' THEN  '/:primary_key.' ||c.conindid
	        WHEN c.contype = 'u' THEN  '/:unique_constraint.' ||c.conindid
	        WHEN c.contype = 'x' THEN  '/:exclusion_constraint.' ||c.conindid
	    END ||':/'|| case when tf.relname is null then c.conname else c.conname || ' -> ' || tf.relname end AS obj_path, n.nspname AS schema_name,
	    True AS show_node, NULL AS other_info
	    from pg_catalog.pg_constraint c
	    left join pg_catalog.pg_class t on c.conrelid = t.oid
	    left join pg_catalog.pg_class tf on c.confrelid = tf.oid
	    left join pg_catalog.pg_namespace n on t.relnamespace = n.oid
	    where c.contypid = 0
	        AND c.contype IN  ('c', 'f', 'p', 'u', 'x')
	        AND CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    select 'rule'::text AS obj_type, r.rulename AS obj_name, ':schema.'||n.oid||':/' || n.nspname|| '/' ||
	            case
	                when t.relkind = 'v' then ':view.' || t.oid || ':' || '/' || t.relname
	                WHEN t.relkind in ('r', 't', 'p') THEN
	                    (
	                        WITH RECURSIVE table_path_data as (
	                            select t.oid as oid, 0 as height, t.relkind,
	                                CASE t.relispartition WHEN true THEN ':partition.' ELSE ':table.' END || t.oid || ':/' || t.relname as path
	                            union
	                            select rel.oid, pt.height+1 as height, rel.relkind,
	                                CASE rel.relispartition WHEN true THEN ':partition.' ELSE ':table.' END
	                                || rel.oid || ':/' || rel.relname || '/' || pt.path as path
	                            from pg_catalog.pg_class rel JOIN pg_catalog.pg_namespace nsp ON rel.relnamespace = nsp.oid
	                            join pg_catalog.pg_inherits inh ON inh.inhparent = rel.oid
	                            join table_path_data pt ON inh.inhrelid = pt.oid
	                        )
	                        select CASE WHEN relkind = 'p' THEN path ELSE ':table.' || t.oid || ':/' || t.relname END AS path
	                        from table_path_data order by height desc limit 1
	                    )
	            end
	            ||'/:rule.'||r.oid||':/'|| r.rulename AS obj_path,
	            n.nspname AS schema_name,
	            True AS show_node, NULL AS other_info
	            from pg_catalog.pg_rewrite r
	    inner join pg_catalog.pg_class t on r.ev_class = t.oid and t.relkind in ('r','t','p','v')
	    left join pg_catalog.pg_namespace n on t.relnamespace = n.oid
	    where CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    select 'trigger'::text AS obj_type, tr.tgname AS obj_name, ':schema.'||n.oid||':/' || n.nspname|| '/' ||
	        case
	            when t.relkind = 'v' then ':view.' || t.oid || ':' || '/' || t.relname
	            WHEN t.relkind in ('r', 't', 'p') THEN
	            (
	                WITH RECURSIVE table_path_data as (
	                    select t.oid as oid, 0 as height, t.relkind,
	                        CASE t.relispartition WHEN true THEN ':partition.' ELSE ':table.' END || t.oid || ':/' || t.relname as path
	                    union
	                    select rel.oid, pt.height+1 as height, rel.relkind,
	                        CASE rel.relispartition WHEN true THEN ':partition.' ELSE ':table.' END
	                        || rel.oid || ':/' || rel.relname || '/' || pt.path as path
	                    from pg_catalog.pg_class rel JOIN pg_catalog.pg_namespace nsp ON rel.relnamespace = nsp.oid
	                    join pg_catalog.pg_inherits inh ON inh.inhparent = rel.oid
	                    join table_path_data pt ON inh.inhrelid = pt.oid
	                )
	                select CASE WHEN relkind = 'p' THEN path ELSE ':table.' || t.oid || ':/' || t.relname END AS path
	                from table_path_data order by height desc limit 1
	            )
	        end || '/:trigger.'|| tr.oid || ':/' || tr.tgname AS obj_path, n.nspname AS schema_name,
	        True AS show_node, NULL AS other_info
	        from pg_catalog.pg_trigger tr
	    inner join pg_catalog.pg_class t on tr.tgrelid = t.oid and t.relkind in ('r', 't', 'p', 'v')
	    left join pg_catalog.pg_namespace n on t.relnamespace = n.oid
	    where tr.tgisinternal = false
	    and CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    SELECT 'type'::text AS obj_type, t.typname AS obj_name, ':schema.'||n.oid||':/' || n.nspname ||
	        '/:type.'|| t.oid ||':/' || t.typname AS obj_path, n.nspname AS schema_name,
	        True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_type t
	    LEFT OUTER JOIN pg_catalog.pg_type e ON e.oid=t.typelem
	    LEFT OUTER JOIN pg_catalog.pg_class ct ON ct.oid=t.typrelid AND ct.relkind <> 'c'
	    LEFT OUTER JOIN pg_catalog.pg_namespace n on t.typnamespace = n.oid
	    WHERE t.typtype != 'd' AND t.typname NOT LIKE E'\\_%'
	            AND ct.oid is NULL
	        AND CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    SELECT 'cast'::text AS obj_type, pg_catalog.format_type(st.oid,NULL) ||'->'|| pg_catalog.format_type(tt.oid,tt.typtypmod) AS obj_name,
	    ':cast.'||ca.oid||':/' || pg_catalog.format_type(st.oid,NULL) ||'->'|| pg_catalog.format_type(tt.oid,tt.typtypmod) AS obj_path, ''::text AS schema_name,
	    True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_cast ca
	    JOIN pg_catalog.pg_type st ON st.oid=castsource
	    JOIN pg_catalog.pg_type tt ON tt.oid=casttarget
	        WHERE ca.oid > 16383::OID
	        UNION

	    SELECT 'publication'::text AS obj_type, pubname AS obj_name, ':publication.'||pub.oid||':/' || pubname AS obj_path, ''::text AS schema_name,
	    True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_publication pub
	    UNION
	    SELECT 'subscription'::text AS obj_type, subname AS obj_name, ':subscription.'||pub.oid||':/' || subname AS obj_path, ''::text AS schema_name,
	    True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_subscription pub
	    UNION
	    SELECT 'language'::text AS obj_type, lanname AS obj_name, ':language.'||lan.oid||':/' || lanname AS obj_path, ''::text AS schema_name,
	    True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_language lan
	    WHERE lanispl IS TRUE
	    UNION
	    SELECT 'fts_configuration'::text AS obj_type, cfg.cfgname AS obj_name, ':schema.'||n.oid||':/' || n.nspname || '/:fts_configuration.'||cfg.oid||':/' || cfg.cfgname AS obj_path, n.nspname AS schema_name,
	    True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_ts_config cfg
	    left join pg_catalog.pg_namespace n on cfg.cfgnamespace = n.oid
	    WHERE CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    SELECT 'fts_dictionary' AS obj_type, dict.dictname AS obj_name, ':schema.'||ns.oid||':/' || ns.nspname || '/:fts_dictionary.'||dict.oid||':/' || dict.dictname AS obj_path, ns.nspname AS schema_name,
	    True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_ts_dict dict
	    left join pg_catalog.pg_namespace ns on dict.dictnamespace = ns.oid
	    WHERE CASE
	    WHEN ns.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    SELECT 'fts_parser' AS obj_type, prs.prsname AS obj_name, ':schema.'||ns.oid||':/' || ns.nspname || '/:fts_parser.'||prs.oid||':/' || prs.prsname AS obj_path, ns.nspname AS schema_name,
	    True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_ts_parser prs
	    left join pg_catalog.pg_namespace ns on prs.prsnamespace = ns.oid
	    WHERE CASE
	    WHEN ns.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    SELECT 'fts_template' AS obj_type, tmpl.tmplname AS obj_name, ':schema.'||ns.oid||':/' || ns.nspname || '/:fts_template.'||tmpl.oid||':/' || tmpl.tmplname AS obj_path, ns.nspname AS schema_name,
	    True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_ts_template tmpl
	    left join pg_catalog.pg_namespace ns on tmpl.tmplnamespace = ns.oid
	    AND CASE
	    WHEN ns.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    select 'domain' AS obj_type, t.typname AS obj_name, ':schema.'||n.oid||':/' || n.nspname || '/:domain.'||t.oid||':/' || t.typname AS obj_path, n.nspname AS schema_name,
	    True AS show_node, NULL AS other_info
	    from pg_catalog.pg_type t
	    inner join pg_catalog.pg_namespace n on t.typnamespace = n.oid
	    where t.typtype = 'd'
	    AND CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    SELECT 'domain_constraints' AS obj_type,
	        c.conname AS obj_name, ':schema.'||n.oid||':/' || n.nspname || '/:domain.'||t.oid||':/' || t.typname || '/:domain_constraints.'||c.oid||':/' || c.conname AS obj_path,
	        n.nspname AS schema_name,
	        True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_constraint c JOIN pg_catalog.pg_type t
	    ON t.oid=contypid JOIN pg_catalog.pg_namespace n
	    ON n.oid=t.typnamespace
	    WHERE t.typtype = 'd'
	    AND CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    select 'foreign_data_wrapper' AS obj_type, fdwname AS obj_name, ':foreign_data_wrapper.'||oid||':/' || fdwname AS obj_path, ''::text AS schema_name,
	    True AS show_node, NULL AS other_info
	    from pg_catalog.pg_foreign_data_wrapper
	    UNION
	    select 'foreign_server' AS obj_type, sr.srvname AS obj_name, ':foreign_data_wrapper.'||fdw.oid||':/' || fdw.fdwname || '/:foreign_server.'||sr.oid||':/' || sr.srvname AS obj_path, ''::text AS schema_name,
	    True AS show_node, NULL AS other_info
	    from pg_catalog.pg_foreign_server sr
	    inner join pg_catalog.pg_foreign_data_wrapper fdw on sr.srvfdw = fdw.oid
	    UNION
	    select 'user_mapping' AS obj_type, um.usename AS obj_name, ':foreign_data_wrapper.'||fdw.oid||':/' || fdw.fdwname || '/:foreign_server.'||sr.oid||':/' || sr.srvname || '/:user_mapping.'||um.umid||':/' || um.usename AS obj_path, ''::text AS schema_name,
	    True AS show_node, NULL AS other_info
	    from pg_catalog.pg_user_mappings um
	    inner join pg_catalog.pg_foreign_server sr on um.srvid = sr.oid
	    inner join pg_catalog.pg_foreign_data_wrapper fdw on sr.srvfdw = fdw.oid
	    UNION
	    select 'foreign_table' AS obj_type, c.relname AS obj_name, ':schema.'||ns.oid||':/' || ns.nspname || '/:foreign_table.'||c.oid||':/' || c.relname AS obj_path, ns.nspname AS schema_name,
	    True AS show_node, NULL AS other_info
	    from pg_catalog.pg_foreign_table ft
	    inner join pg_catalog.pg_class c on ft.ftrelid = c.oid
	    inner join pg_catalog.pg_namespace ns on c.relnamespace = ns.oid
	    AND CASE
	    WHEN ns.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    select 'extension' AS obj_type, x.extname AS obj_name, ':extension.'||x.oid||':/' || x.extname AS obj_path, ''::text AS schema_name,
	    True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_extension x
	    JOIN pg_catalog.pg_namespace n on x.extnamespace=n.oid
	    join pg_catalog.pg_available_extensions() e(name, default_version, comment) ON x.extname=e.name
	    UNION
	    SELECT 'collation' AS obj_type, c.collname AS obj_name, ':schema.'||n.oid||':/' || n.nspname || '/:collation.'||c.oid||':/' || c.collname AS obj_path, n.nspname AS schema_name,
	    True AS show_node, NULL AS other_info
	    FROM pg_catalog.pg_collation c
	    JOIN pg_catalog.pg_namespace n ON n.oid=c.collnamespace
	    WHERE CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    select 'row_security_policy'::text AS obj_type, pl.polname AS obj_name, ':schema.'||n.oid||':/' || n.nspname|| '/' ||
	            case
	                WHEN t.relkind in ('r', 't', 'p') THEN
	                    (
	                        WITH RECURSIVE table_path_data as (
	                            select t.oid as oid, 0 as height, t.relkind,
	                                CASE t.relispartition WHEN true THEN ':partition.' ELSE ':table.' END || t.oid || ':/' || t.relname as path
	                            union
	                            select rel.oid, pt.height+1 as height, rel.relkind,
	                                CASE rel.relispartition WHEN true THEN ':partition.' ELSE ':table.' END
	                                || rel.oid || ':/' || rel.relname || '/' || pt.path as path
	                            from pg_catalog.pg_class rel JOIN pg_catalog.pg_namespace nsp ON rel.relnamespace = nsp.oid
	                            join pg_catalog.pg_inherits inh ON inh.inhparent = rel.oid
	                            join table_path_data pt ON inh.inhrelid = pt.oid
	                        )
	                        select CASE WHEN relkind = 'p' THEN path ELSE ':table.' || t.oid || ':/' || t.relname END AS path
	                        from table_path_data order by height desc limit 1
	                    )
	            end
	            ||'/:row_security_policy.'|| pl.oid ||':/'|| pl.polname AS obj_path, n.nspname AS schema_name,
	            True AS show_node, NULL AS other_info
	            FROM pg_catalog.pg_policy pl
	    JOIN pg_catalog.pg_class t on pl.polrelid = t.oid and t.relkind in ('r','t','p')
	    JOIN pg_catalog.pg_policies rw ON (pl.polname=rw.policyname AND t.relname=rw.tablename)
	    JOIN pg_catalog.pg_namespace n on t.relnamespace = n.oid
	    where CASE
	    WHEN n.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END
	    UNION
	    SELECT 'aggregate' AS obj_type, pr.proname AS obj_name,
	    ':schema.'|| ns.oid || ':/' || ns.nspname || '/' || ':aggregate.' || ag.aggfnoid::oid ||':/' || pr.proname AS obj_path,
	    ns.nspname AS schema_name,
	    True AS show_node, pg_catalog.pg_get_function_arguments(aggfnoid::oid) AS other_info
	    FROM pg_aggregate ag
	    LEFT OUTER JOIN pg_catalog.pg_proc pr ON pr.oid = ag.aggfnoid
	    LEFT OUTER JOIN pg_catalog.pg_namespace ns ON ns.oid=pr.pronamespace
	    WHERE (CASE
	    WHEN ns.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END)
	    UNION
	    SELECT 'operator' AS obj_type, op.oprname AS obj_name,
	    ':schema.'|| ns.oid || ':/' || ns.nspname || '/' || ':operator.' || op.oid::oid ||':/' || op.oprname AS obj_path,
	    ns.nspname AS schema_name,
	    True AS show_node,
	    CASE WHEN lt.typname IS NOT NULL AND rt.typname IS NOT NULL THEN
			pg_catalog.format_type(lt.oid, NULL) || ', ' || pg_catalog.format_type(rt.oid, NULL)
		 WHEN lt.typname IS NULL AND rt.typname IS NOT NULL THEN
		    pg_catalog.format_type(rt.oid, NULL)
		 WHEN lt.typname IS NOT NULL AND rt.typname IS NULL THEN
		    pg_catalog.format_type(lt.oid, NULL)
		 ELSE '' END AS other_info
	    FROM pg_catalog.pg_operator op
	    LEFT OUTER JOIN pg_catalog.pg_namespace ns ON ns.oid=op.oprnamespace
	    LEFT OUTER JOIN pg_catalog.pg_type lt ON lt.oid=op.oprleft
	    LEFT OUTER JOIN pg_catalog.pg_type rt ON rt.oid=op.oprright
	    WHERE (CASE
	    WHEN ns.nspname = ANY('{information_schema}')
	        THEN false
	    ELSE true END)

	) sn
	where lower(sn.obj_name) like '%table333%'
	AND NOT (sn.schema_name IN ('pg_catalog', 'pgagent', 'information_schema'))
	AND (sn.schema_name IS NOT NULL AND sn.schema_name NOT LIKE 'pg\_%')
	ORDER BY 1, 2, 3
