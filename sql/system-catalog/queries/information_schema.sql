-- Query for getting functions

SELECT
    COALESCE(
        json_agg(Row_to_json(functions)),
        '[]' :: JSON
    )
from
    (
        SELECT
            *
        FROM
            (
                SELECT
                    p.proname :: text AS function_name,
                    pn.nspname :: text AS function_schema,
                    pd.description,
                    CASE
                        WHEN p.provariadic = 0 :: oid THEN false
                        ELSE true
                    END AS has_variadic,
                    CASE
                        WHEN p.provolatile :: text = 'i' :: character(1) :: text THEN 'IMMUTABLE' :: text
                        WHEN p.provolatile :: text = 's' :: character(1) :: text THEN 'STABLE' :: text
                        WHEN p.provolatile :: text = 'v' :: character(1) :: text THEN 'VOLATILE' :: text
                        ELSE NULL :: text
                    END AS function_type,
                    pg_get_functiondef(p.oid) AS function_definition,
                    rtn.nspname :: text AS return_type_schema,
                    rt.typname :: text AS return_type_name,
                    rt.typtype :: text AS return_type_type,
                    obj_description(p.oid) AS comment,
                    p.proretset AS returns_set,
                    (
                        SELECT
                            COALESCE(
                                json_agg(
                                    json_build_object(
                                        'schema',
                                        q.schema,
                                        'name',
                                        q.name,
                                        'type',
                                        q.type
                                    )
                                ),
                                '[]' :: json
                            ) AS "coalesce"
                        FROM
                            (
                                SELECT
                                    pt.typname AS name,
                                    pns.nspname AS schema,
                                    pt.typtype AS type,
                                    pat.ordinality
                                FROM
                                    unnest(
                                        COALESCE(p.proallargtypes, p.proargtypes :: oid [])
                                    ) WITH ORDINALITY pat(oid, ordinality)
                                    LEFT JOIN pg_type pt ON pt.oid = pat.oid
                                    LEFT JOIN pg_namespace pns ON pt.typnamespace = pns.oid
                                ORDER BY
                                    pat.ordinality
                            ) q
                    ) AS input_arg_types,
                    to_json(COALESCE(p.proargnames, ARRAY [] :: text [])) AS input_arg_names,
                    p.pronargdefaults AS default_args,
                    p.oid :: integer AS function_oid
                FROM
                    pg_proc p
                    JOIN pg_namespace pn ON pn.oid = p.pronamespace
                    JOIN pg_type rt ON rt.oid = p.prorettype
                    JOIN pg_namespace rtn ON rtn.oid = rt.typnamespace
                    LEFT JOIN pg_description pd ON p.oid = pd.objoid
                WHERE
                    pn.nspname :: text !~~ 'pg_%' :: text
                    AND(
                        pn.nspname :: text <> ALL (ARRAY ['information_schema'::text])
                    )
                    AND NOT(
                        EXISTS (
                            SELECT
                                1
                            FROM
                                pg_aggregate
                            WHERE
                                pg_aggregate.aggfnoid :: oid = p.oid
                        )
                    )
            ) as info -- WHERE function_schema='schema'
        WHERE
            function_schema = 'schema'
            AND has_variadic = FALSE
            AND return_type_type = 'c'
        ORDER BY
            function_name ASC
    ) as functions;

-- Disable this query for now
-- Query for getting a table

-- SELECT
-- 	    COALESCE(Json_agg(Row_to_json(info)), '[]' :: json) AS tables
-- 	  FROM (
-- 	    WITH partitions AS (
-- 	      SELECT array(
-- 	        WITH partitioned_tables AS (SELECT array(SELECT oid FROM pg_class WHERE relkind = 'p') AS parent_tables)
-- 	        SELECT
-- 	        child.relname       AS partition
-- 	    FROM partitioned_tables, pg_inherits
-- 	        JOIN pg_class child             ON pg_inherits.inhrelid   = child.oid
-- 	        JOIN pg_namespace nmsp_child    ON nmsp_child.oid   = child.relnamespace
-- 	    where ((nmsp_child.nspname='public'))
-- 	    AND pg_inherits.inhparent = ANY (partitioned_tables.parent_tables)
-- 	      ) AS names
-- 	    )
-- 	    SELECT
-- 	      pgn.nspname AS table_schema,
-- 	      pgc.relname AS table_name,
-- 	      CASE
-- 	        WHEN pgc.relkind = 'r' THEN 'TABLE'
-- 	        WHEN pgc.relkind = 'f' THEN 'FOREIGN TABLE'
-- 	        WHEN pgc.relkind = 'v' THEN 'VIEW'
-- 	        WHEN pgc.relkind = 'm' THEN 'MATERIALIZED VIEW'
-- 	        WHEN pgc.relkind = 'p' THEN 'PARTITIONED TABLE'
-- 	      END AS table_type,
-- 	      obj_description(pgc.oid) AS comment,
-- 	      COALESCE(json_agg(DISTINCT row_to_json(isc) :: jsonb || jsonb_build_object('comment', col_description(pga.attrelid, pga.attnum))) filter (WHERE isc.column_name IS NOT NULL), '[]' :: json) AS columns,
-- 	      COALESCE(json_agg(DISTINCT row_to_json(ist) :: jsonb || jsonb_build_object('comment', obj_description(pgt.oid))) filter (WHERE ist.trigger_name IS NOT NULL), '[]' :: json) AS triggers,
-- 	      row_to_json(isv) AS view_info
-- 	      FROM partitions, pg_class as pgc  
-- 	      INNER JOIN pg_namespace as pgn
-- 	        ON pgc.relnamespace = pgn.oid
-- 	    /* columns */
-- 	    /* This is a simplified version of how information_schema.columns was
-- 	    ** implemented in postgres 9.5, but modified to support materialized
-- 	    ** views.
-- 	    */
-- 	    LEFT OUTER JOIN pg_attribute AS pga
-- 	      ON pga.attrelid = pgc.oid
-- 	    LEFT OUTER JOIN (
-- 	      SELECT
-- 	        nc.nspname         AS table_schema,
-- 	        c.relname          AS table_name,
-- 	        a.attname          AS column_name,
-- 	        a.attnum           AS ordinal_position,
-- 	        pg_get_expr(ad.adbin, ad.adrelid) AS column_default,
-- 	        CASE WHEN a.attnotnull OR (t.typtype = 'd' AND t.typnotnull) THEN 'NO' ELSE 'YES' END AS is_nullable,
-- 	        CASE WHEN t.typtype = 'd' THEN
-- 	          CASE WHEN bt.typelem <> 0 AND bt.typlen = -1 THEN 'ARRAY'
-- 	               WHEN nbt.nspname = 'pg_catalog' THEN format_type(t.typbasetype, null)
-- 	               ELSE 'USER-DEFINED' END
-- 	        ELSE
-- 	          CASE WHEN t.typelem <> 0 AND t.typlen = -1 THEN 'ARRAY'
-- 	               WHEN nt.nspname = 'pg_catalog' THEN format_type(a.atttypid, null)
-- 	               ELSE 'USER-DEFINED' END
-- 	        END AS data_type,
-- 	        coalesce(bt.typname, t.typname) AS data_type_name
-- 	      FROM (pg_attribute a LEFT JOIN pg_attrdef ad ON attrelid = adrelid AND attnum = adnum)
-- 	        JOIN (pg_class c JOIN pg_namespace nc ON (c.relnamespace = nc.oid)) ON a.attrelid = c.oid
-- 	        JOIN (pg_type t JOIN pg_namespace nt ON (t.typnamespace = nt.oid)) ON a.atttypid = t.oid
-- 	        LEFT JOIN (pg_type bt JOIN pg_namespace nbt ON (bt.typnamespace = nbt.oid))
-- 	          ON (t.typtype = 'd' AND t.typbasetype = bt.oid)
-- 	        LEFT JOIN (pg_collation co JOIN pg_namespace nco ON (co.collnamespace = nco.oid))
-- 	          ON a.attcollation = co.oid AND (nco.nspname, co.collname) <> ('pg_catalog', 'default')
-- 	      WHERE (NOT pg_is_other_temp_schema(nc.oid))
-- 	        AND a.attnum > 0 AND NOT a.attisdropped AND c.relkind in ('r', 'v', 'm', 'f', 'p')
-- 	        AND (pg_has_role(c.relowner, 'USAGE')
-- 	             OR has_column_privilege(c.oid, a.attnum,
-- 	                                     'SELECT, INSERT, UPDATE, REFERENCES'))
-- 	    ) AS isc
-- 	      ON  isc.table_schema = pgn.nspname
-- 	      AND isc.table_name   = pgc.relname
-- 	      AND isc.column_name  = pga.attname
	  
-- 	    /* triggers */
-- 	    LEFT OUTER JOIN pg_trigger AS pgt
-- 	      ON pgt.tgrelid = pgc.oid
-- 	    LEFT OUTER JOIN information_schema.triggers AS ist
-- 	      ON  ist.event_object_schema = pgn.nspname
-- 	      AND ist.event_object_table  = pgc.relname
-- 	      AND ist.trigger_name        = pgt.tgname
	  
-- 	    /* This is a simplified version of how information_schema.views was
-- 	    ** implemented in postgres 9.5, but modified to support materialized
-- 	    ** views.
-- 	    */
-- 	    LEFT OUTER JOIN (
-- 	      SELECT
-- 	        nc.nspname         AS table_schema,
-- 	        c.relname          AS table_name,
-- 	        CASE WHEN pg_has_role(c.relowner, 'USAGE') THEN pg_get_viewdef(c.oid) ELSE null END AS view_definition,
-- 	        CASE WHEN pg_relation_is_updatable(c.oid, false) & 20 = 20 THEN 'YES' ELSE 'NO' END AS is_updatable,
-- 	        CASE WHEN pg_relation_is_updatable(c.oid, false) &  8 =  8 THEN 'YES' ELSE 'NO' END AS is_insertable_into,
-- 	        CASE WHEN EXISTS (SELECT 1 FROM pg_trigger WHERE tgrelid = c.oid AND tgtype & 81 = 81) THEN 'YES' ELSE 'NO' END AS is_trigger_updatable,
-- 	        CASE WHEN EXISTS (SELECT 1 FROM pg_trigger WHERE tgrelid = c.oid AND tgtype & 73 = 73) THEN 'YES' ELSE 'NO' END AS is_trigger_deletable,
-- 	        CASE WHEN EXISTS (SELECT 1 FROM pg_trigger WHERE tgrelid = c.oid AND tgtype & 69 = 69) THEN 'YES' ELSE 'NO' END AS is_trigger_insertable_into
-- 	      FROM pg_namespace nc, pg_class c
	  
-- 	      WHERE c.relnamespace = nc.oid
-- 	        AND c.relkind in ('v', 'm')
-- 	        AND (NOT pg_is_other_temp_schema(nc.oid))
-- 	        AND (pg_has_role(c.relowner, 'USAGE')
-- 	             OR has_table_privilege(c.oid, 'SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER')
-- 	             OR has_any_column_privilege(c.oid, 'SELECT, INSERT, UPDATE, REFERENCES'))
-- 	    ) AS isv
-- 	      ON  isv.table_schema = pgn.nspname
-- 	      AND isv.table_name   = pgc.relname
	  
-- 	    WHERE
-- 	      pgc.relkind IN ('r', 'v', 'f', 'm', 'p')
-- 	      and ((pgn.nspname='public'))
-- 	    GROUP BY pgc.oid, pgn.nspname, pgc.relname, table_type, isv.*
-- 	  ) AS info;

-- Taken from https://github.com/yugabyte/yugabyte-db/issues/7745

SELECT c.column_name, c.is_nullable = 'YES', c.udt_name, c.character_maximum_length, c.numeric_precision,
c.numeric_precision_radix, c.numeric_scale, c.datetime_precision, 8 * typlen, c.column_default, pd.description,
c.identity_increment
FROM information_schema.columns AS c
JOIN pg_type AS pgt ON c.udt_name = pgt.typname
LEFT JOIN pg_catalog.pg_description as pd ON pd.objsubid = c.ordinal_position AND pd.objoid = (
  SELECT oid FROM pg_catalog.pg_class
  WHERE relname = c.table_name AND relnamespace = (
    SELECT oid FROM pg_catalog.pg_namespace
    WHERE nspname = c.table_schema
    )
  )
where table_catalog = 'yugabyte' AND table_schema = 'clusters' AND table_name = 'clusters';

-- Arbitrarily query from all information_schema views.

select * from information_schema.applicable_roles;
select * from information_schema.attributes;
select * from information_schema.character_sets;
select * from information_schema.check_constraint_routine_usage;
select * from information_schema.check_constraints;
select * from information_schema.collations;
select * from information_schema.collation_character_set_applicability;
select * from information_schema.column_domain_usage;
select * from information_schema.column_options;
select * from information_schema.column_privileges;
select * from information_schema.column_udt_usage;
select * from information_schema.columns;
select * from information_schema.constraint_column_usage;
select * from information_schema.constraint_table_usage;
select * from information_schema.data_type_privileges;
select * from information_schema.domain_constraints;
select * from information_schema.domain_udt_usage;
select * from information_schema.domains;
select * from information_schema.element_types;
select * from information_schema.enabled_roles;
select * from information_schema.foreign_data_wrapper_options;
select * from information_schema.foreign_data_wrappers;
select * from information_schema.foreign_server_options;
select * from information_schema.foreign_servers;
select * from information_schema.foreign_table_options;
select * from information_schema.foreign_tables;
select * from information_schema.key_column_usage;
select * from information_schema.parameters;
select * from information_schema.referential_constraints;
select * from information_schema.role_column_grants;
select * from information_schema.role_routine_grants;
select * from information_schema.role_table_grants;
select * from information_schema.role_udt_grants;
select * from information_schema.role_usage_grants;
select * from information_schema.routine_privileges;
select * from information_schema.routines;
select * from information_schema.schemata;
select * from information_schema.sequences;
select * from information_schema.sql_features;
select * from information_schema.sql_implementation_info;
select * from information_schema.sql_parts;
select * from information_schema.sql_sizing;
select * from information_schema.table_constraints;
select * from information_schema.table_privileges;
select * from information_schema.tables;
select * from information_schema.transforms;
select * from information_schema.triggered_update_columns;
select * from information_schema.triggers;
select * from information_schema.udt_privileges;
select * from information_schema.usage_privileges;
select * from information_schema.user_defined_types;
select * from information_schema.user_mapping_options;
select * from information_schema.user_mappings;
select * from information_schema.view_column_usage;
select * from information_schema.view_routine_usage;
select * from information_schema.view_table_usage;
select * from information_schema.views;
