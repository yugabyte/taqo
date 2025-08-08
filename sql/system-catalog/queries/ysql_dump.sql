SELECT
	n.tableoid,
	n.oid,
	n.nspname,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = nspowner
	) AS rolname,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(n.nspacl, pg_catalog.acldefault('n', n.nspowner))
					) WITH ORDINALITY AS perm(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									pip.initprivs,
									pg_catalog.acldefault('n', n.nspowner)
								)
							) AS init(init_acl)
						WHERE
							acl = init_acl
					)
			) as foo
	) as nspacl,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							pip.initprivs,
							pg_catalog.acldefault('n', n.nspowner)
						)
					) WITH ORDINALITY AS initp(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(n.nspacl, pg_catalog.acldefault('n', n.nspowner))
							) AS permp(orig_acl)
						WHERE
							acl = orig_acl
					)
			) as foo
	) as rnspacl,
	NULL as initnspacl,
	NULL as initrnspacl
FROM
	pg_namespace n
	LEFT JOIN pg_init_privs pip ON (
		n.oid = pip.objoid
		AND pip.classoid = 'pg_namespace' :: regclass
		AND pip.objsubid = 0
	);

SELECT
	c.tableoid,
	c.oid,
	c.relname,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							c.relacl,
							pg_catalog.acldefault(
								CASE
									WHEN c.relkind = 'S' THEN 's'
									ELSE 'r'
								END :: "char",
								c.relowner
							)
						)
					) WITH ORDINALITY AS perm(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									pip.initprivs,
									pg_catalog.acldefault(
										CASE
											WHEN c.relkind = 'S' THEN 's'
											ELSE 'r'
										END :: "char",
										c.relowner
									)
								)
							) AS init(init_acl)
						WHERE
							acl = init_acl
					)
			) as foo
	) AS relacl,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							pip.initprivs,
							pg_catalog.acldefault(
								CASE
									WHEN c.relkind = 'S' THEN 's'
									ELSE 'r'
								END :: "char",
								c.relowner
							)
						)
					) WITH ORDINALITY AS initp(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									c.relacl,
									pg_catalog.acldefault(
										CASE
											WHEN c.relkind = 'S' THEN 's'
											ELSE 'r'
										END :: "char",
										c.relowner
									)
								)
							) AS permp(orig_acl)
						WHERE
							acl = orig_acl
					)
			) as foo
	) as rrelacl,
	NULL AS initrelacl,
	NULL as initrrelacl,
	c.relkind,
	c.relnamespace,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = c.relowner
	) AS rolname,
	c.relchecks,
	c.relhastriggers,
	c.relhasindex,
	c.relhasrules,
	c.relrowsecurity,
	c.relforcerowsecurity,
	c.relfrozenxid,
	c.relminmxid,
	tc.oid AS toid,
	tc.relfrozenxid AS tfrozenxid,
	tc.relminmxid AS tminmxid,
	c.relpersistence,
	c.relispopulated,
	c.relreplident,
	c.relpages,
	CASE
		WHEN c.reloftype <> 0 THEN c.reloftype :: pg_catalog.regtype
		ELSE NULL
	END AS reloftype,
	d.refobjid AS owning_tab,
	d.refobjsubid AS owning_col,
	(
		SELECT
			spcname
		FROM
			pg_tablespace t
		WHERE
			t.oid = c.reltablespace
	) AS reltablespace,
	array_remove(
		array_remove(c.reloptions, 'check_option=local'),
		'check_option=cascaded'
	) AS reloptions,
	CASE
		WHEN 'check_option=local' = ANY (c.reloptions) THEN 'LOCAL' :: text
		WHEN 'check_option=cascaded' = ANY (c.reloptions) THEN 'CASCADED' :: text
		ELSE NULL
	END AS checkoption,
	tc.reloptions AS toast_reloptions,
	c.relkind = 'S'
	AND EXISTS (
		SELECT
			1
		FROM
			pg_depend
		WHERE
			classid = 'pg_class' :: regclass
			AND objid = c.oid
			AND objsubid = 0
			AND refclassid = 'pg_class' :: regclass
			AND deptype = 'i'
	) AS is_identity_sequence,
	EXISTS (
		SELECT
			1
		FROM
			pg_attribute at
			LEFT JOIN pg_init_privs pip ON (
				c.oid = pip.objoid
				AND pip.classoid = 'pg_class' :: regclass
				AND pip.objsubid = at.attnum
			)
		WHERE
			at.attrelid = c.oid
			AND (
				(
					SELECT
						pg_catalog.array_agg(
							acl
							ORDER BY
								row_n
						)
					FROM
						(
							SELECT
								acl,
								row_n
							FROM
								pg_catalog.unnest(
									coalesce(
										at.attacl,
										pg_catalog.acldefault('c', c.relowner)
									)
								) WITH ORDINALITY AS perm(acl, row_n)
							WHERE
								NOT EXISTS (
									SELECT
										1
									FROM
										pg_catalog.unnest(
											coalesce(
												pip.initprivs,
												pg_catalog.acldefault('c', c.relowner)
											)
										) AS init(init_acl)
									WHERE
										acl = init_acl
								)
						) as foo
				) IS NOT NULL
				OR (
					SELECT
						pg_catalog.array_agg(
							acl
							ORDER BY
								row_n
						)
					FROM
						(
							SELECT
								acl,
								row_n
							FROM
								pg_catalog.unnest(
									coalesce(
										pip.initprivs,
										pg_catalog.acldefault('c', c.relowner)
									)
								) WITH ORDINALITY AS initp(acl, row_n)
							WHERE
								NOT EXISTS (
									SELECT
										1
									FROM
										pg_catalog.unnest(
											coalesce(
												at.attacl,
												pg_catalog.acldefault('c', c.relowner)
											)
										) AS permp(orig_acl)
									WHERE
										acl = orig_acl
								)
						) as foo
				) IS NOT NULL
				OR NULL IS NOT NULL
				OR NULL IS NOT NULL
			)
	) AS changed_acl,
	pg_get_partkeydef(c.oid) AS partkeydef,
	c.relispartition AS ispartition,
	pg_get_expr(c.relpartbound, c.oid) AS partbound
FROM
	pg_class c
	LEFT JOIN pg_depend d ON (
		c.relkind = 'S'
		AND d.classid = c.tableoid
		AND d.objid = c.oid
		AND d.objsubid = 0
		AND d.refclassid = c.tableoid
		AND d.deptype IN ('a', 'i')
	)
	LEFT JOIN pg_class tc ON (c.reltoastrelid = tc.oid)
	LEFT JOIN pg_init_privs pip ON (
		c.oid = pip.objoid
		AND pip.classoid = 'pg_class' :: regclass
		AND pip.objsubid = 0
	)
WHERE
	c.relkind in ('r', 'S', 'v', 'c', 'm', 'f', 'p')
ORDER BY
	c.oid;

SELECT
	p.tableoid,
	p.oid,
	p.proname,
	p.prolang,
	p.pronargs,
	p.proargtypes,
	p.prorettype,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(p.proacl, pg_catalog.acldefault('f', p.proowner))
					) WITH ORDINALITY AS perm(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									pip.initprivs,
									pg_catalog.acldefault('f', p.proowner)
								)
							) AS init(init_acl)
						WHERE
							acl = init_acl
					)
			) as foo
	) AS proacl,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							pip.initprivs,
							pg_catalog.acldefault('f', p.proowner)
						)
					) WITH ORDINALITY AS initp(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(p.proacl, pg_catalog.acldefault('f', p.proowner))
							) AS permp(orig_acl)
						WHERE
							acl = orig_acl
					)
			) as foo
	) AS rproacl,
	NULL AS initproacl,
	NULL AS initrproacl,
	p.pronamespace,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = p.proowner
	) AS rolname
FROM
	pg_proc p
	LEFT JOIN pg_init_privs pip ON (
		p.oid = pip.objoid
		AND pip.classoid = 'pg_proc' :: regclass
		AND pip.objsubid = 0
	)
WHERE
	p.prokind <> 'a'
	AND NOT EXISTS (
		SELECT
			1
		FROM
			pg_depend
		WHERE
			classid = 'pg_proc' :: regclass
			AND objid = p.oid
			AND deptype = 'i'
	)
	AND (
		pronamespace != (
			SELECT
				oid
			FROM
				pg_namespace
			WHERE
				nspname = 'pg_catalog'
		)
		OR EXISTS (
			SELECT
				1
			FROM
				pg_cast
			WHERE
				pg_cast.oid > 16383
				AND p.oid = pg_cast.castfunc
		)
		OR EXISTS (
			SELECT
				1
			FROM
				pg_transform
			WHERE
				pg_transform.oid > 16383
				AND (
					p.oid = pg_transform.trffromsql
					OR p.oid = pg_transform.trftosql
				)
		)
		OR p.proacl IS DISTINCT
		FROM
			pip.initprivs
	);

SELECT
	t.tableoid,
	t.oid,
	t.typname,
	t.typnamespace,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(t.typacl, pg_catalog.acldefault('T', t.typowner))
					) WITH ORDINALITY AS perm(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									pip.initprivs,
									pg_catalog.acldefault('T', t.typowner)
								)
							) AS init(init_acl)
						WHERE
							acl = init_acl
					)
			) as foo
	) AS typacl,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							pip.initprivs,
							pg_catalog.acldefault('T', t.typowner)
						)
					) WITH ORDINALITY AS initp(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(t.typacl, pg_catalog.acldefault('T', t.typowner))
							) AS permp(orig_acl)
						WHERE
							acl = orig_acl
					)
			) as foo
	) AS rtypacl,
	NULL AS inittypacl,
	NULL AS initrtypacl,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = t.typowner
	) AS rolname,
	t.typelem,
	t.typrelid,
	CASE
		WHEN t.typrelid = 0 THEN ' ' :: "char"
		ELSE (
			SELECT
				relkind
			FROM
				pg_class
			WHERE
				oid = t.typrelid
		)
	END AS typrelkind,
	t.typtype,
	t.typisdefined,
	t.typname [0] = '_'
	AND t.typelem != 0
	AND (
		SELECT
			typarray
		FROM
			pg_type te
		WHERE
			oid = t.typelem
	) = t.oid AS isarray
FROM
	pg_type t
	LEFT JOIN pg_init_privs pip ON (
		t.oid = pip.objoid
		AND pip.classoid = 'pg_type' :: regclass
		AND pip.objsubid = 0
	);

SELECT
	l.tableoid,
	l.oid,
	l.lanname,
	l.lanpltrusted,
	l.lanplcallfoid,
	l.laninline,
	l.lanvalidator,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(l.lanacl, pg_catalog.acldefault('l', l.lanowner))
					) WITH ORDINALITY AS perm(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									pip.initprivs,
									pg_catalog.acldefault('l', l.lanowner)
								)
							) AS init(init_acl)
						WHERE
							acl = init_acl
					)
			) as foo
	) AS lanacl,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							pip.initprivs,
							pg_catalog.acldefault('l', l.lanowner)
						)
					) WITH ORDINALITY AS initp(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(l.lanacl, pg_catalog.acldefault('l', l.lanowner))
							) AS permp(orig_acl)
						WHERE
							acl = orig_acl
					)
			) as foo
	) AS rlanacl,
	NULL AS initlanacl,
	NULL AS initrlanacl,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = l.lanowner
	) AS lanowner
FROM
	pg_language l
	LEFT JOIN pg_init_privs pip ON (
		l.oid = pip.objoid
		AND pip.classoid = 'pg_language' :: regclass
		AND pip.objsubid = 0
	)
WHERE
	l.lanispl
ORDER BY
	l.oid;

SELECT
	p.tableoid,
	p.oid,
	p.proname AS aggname,
	p.pronamespace AS aggnamespace,
	p.pronargs,
	p.proargtypes,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = p.proowner
	) AS rolname,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(p.proacl, pg_catalog.acldefault('f', p.proowner))
					) WITH ORDINALITY AS perm(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									pip.initprivs,
									pg_catalog.acldefault('f', p.proowner)
								)
							) AS init(init_acl)
						WHERE
							acl = init_acl
					)
			) as foo
	) AS aggacl,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							pip.initprivs,
							pg_catalog.acldefault('f', p.proowner)
						)
					) WITH ORDINALITY AS initp(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(p.proacl, pg_catalog.acldefault('f', p.proowner))
							) AS permp(orig_acl)
						WHERE
							acl = orig_acl
					)
			) as foo
	) AS raggacl,
	NULL AS initaggacl,
	NULL AS initraggacl
FROM
	pg_proc p
	LEFT JOIN pg_init_privs pip ON (
		p.oid = pip.objoid
		AND pip.classoid = 'pg_proc' :: regclass
		AND pip.objsubid = 0
	)
WHERE
	p.prokind = 'a'
	AND (
		p.pronamespace != (
			SELECT
				oid
			FROM
				pg_namespace
			WHERE
				nspname = 'pg_catalog'
		)
		OR p.proacl IS DISTINCT
		FROM
			pip.initprivs
	);

SELECT
	grpname,
	tg.oid,
	grpoptions,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = grpowner
	) AS owner,
	(
		SELECT
			spcname
		FROM
			pg_tablespace t
		WHERE
			t.oid = grptablespace
	) AS grptablespace,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							tg.grpacl,
							pg_catalog.acldefault('g', tg.grpowner)
						)
					) WITH ORDINALITY AS perm(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									pip.initprivs,
									pg_catalog.acldefault('g', tg.grpowner)
								)
							) AS init(init_acl)
						WHERE
							acl = init_acl
					)
			) as foo
	) AS acl,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							pip.initprivs,
							pg_catalog.acldefault('g', tg.grpowner)
						)
					) WITH ORDINALITY AS initp(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									tg.grpacl,
									pg_catalog.acldefault('g', tg.grpowner)
								)
							) AS permp(orig_acl)
						WHERE
							acl = orig_acl
					)
			) as foo
	) AS racl,
	NULL AS initacl,
	NULL AS initracl
FROM
	pg_yb_tablegroup AS tg
	LEFT JOIN pg_init_privs pip ON tg.oid = pip.objoid;


SELECT
	tableoid,
	oid,
	opfname,
	opfnamespace,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = opfowner
	) AS rolname
FROM
	pg_opfamily;

SELECT
	f.tableoid,
	f.oid,
	f.fdwname,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = f.fdwowner
	) AS rolname,
	f.fdwhandler :: pg_catalog.regproc,
	f.fdwvalidator :: pg_catalog.regproc,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(f.fdwacl, pg_catalog.acldefault('F', f.fdwowner))
					) with ordinality AS perm(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									pip.initprivs,
									pg_catalog.acldefault('F', f.fdwowner)
								)
							) AS init(init_acl)
						WHERE
							acl = init_acl
					)
			) as foo
	) AS fdwacl,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							pip.initprivs,
							pg_catalog.acldefault('F', f.fdwowner)
						)
					) with ordinality as initp(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(f.fdwacl, pg_catalog.acldefault('F', f.fdwowner))
							) AS permp(orig_acl)
						WHERE
							acl = orig_acl
					)
			) as foo
	) AS rfdwacl,
	NULL AS initfdwacl,
	NULL AS initrfdwacl,
	array_to_string(
		ARRAY(
			SELECT
				quote_ident(option_name) || ' ' || quote_literal(option_value)
			FROM
				pg_options_to_table(f.fdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS fdwoptions
FROM
	pg_foreign_data_wrapper f
	LEFT JOIN pg_init_privs pip ON (
		f.oid = pip.objoid
		AND pip.classoid = 'pg_foreign_data_wrapper' :: regclass
		AND pip.objsubid = 0
	);

SELECT
	f.tableoid,
	f.oid,
	f.srvname,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = f.srvowner
	) AS rolname,
	f.srvfdw,
	f.srvtype,
	f.srvversion,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(f.srvacl, pg_catalog.acldefault('S', f.srvowner))
					) WITH ORDINALITY AS perm(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									pip.initprivs,
									pg_catalog.acldefault('S', f.srvowner)
								)
							) AS init(init_acl)
						WHERE
							acl = init_acl
					)
			) as foo
	) AS srvacl,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							pip.initprivs,
							pg_catalog.acldefault('S', f.srvowner)
						)
					) WITH ORDINALITY AS initp(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(f.srvacl, pg_catalog.acldefault('S', f.srvowner))
							) AS permp(orig_acl)
						WHERE
							acl = orig_acl
					)
			) as foo
	) AS rsrvacl,
	NULL AS initsrvacl,
	NULL AS initrsrvacl,
	array_to_string(
		ARRAY(
			SELECT
				quote_ident(option_name) || ' ' || quote_literal(option_value)
			FROM
				pg_options_to_table(f.srvoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS srvoptions
FROM
	pg_foreign_server f
	LEFT JOIN pg_init_privs pip ON (
		f.oid = pip.objoid
		AND pip.classoid = 'pg_foreign_server' :: regclass
		AND pip.objsubid = 0
	);

SELECT
	d.oid,
	d.tableoid,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = d.defaclrole
	) AS defaclrole,
	d.defaclnamespace,
	d.defaclobjtype,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							defaclacl,
							pg_catalog.acldefault(
								CASE
									WHEN defaclnamespace = 0 THEN CASE
										WHEN defaclobjtype = 'S' THEN 's' :: "char"
										ELSE defaclobjtype
									END
									ELSE NULL
								END,
								defaclrole
							)
						)
					) WITH ORDINALITY AS perm(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									pip.initprivs,
									pg_catalog.acldefault(
										CASE
											WHEN defaclnamespace = 0 THEN CASE
												WHEN defaclobjtype = 'S' THEN 's' :: "char"
												ELSE defaclobjtype
											END
											ELSE NULL
										END,
										defaclrole
									)
								)
							) AS init(init_acl)
						WHERE
							acl = init_acl
					)
			) as foo
	) AS defaclacl,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							pip.initprivs,
							pg_catalog.acldefault(
								CASE
									WHEN defaclnamespace = 0 THEN CASE
										WHEN defaclobjtype = 'S' THEN 's' :: "char"
										ELSE defaclobjtype
									END
									ELSE NULL
								END,
								defaclrole
							)
						)
					) WITH ORDINALITY AS initp(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									defaclacl,
									pg_catalog.acldefault(
										CASE
											WHEN defaclnamespace = 0 THEN CASE
												WHEN defaclobjtype = 'S' THEN 's' :: "char"
												ELSE defaclobjtype
											END
											ELSE NULL
										END,
										defaclrole
									)
								)
							) AS permp(orig_acl)
						WHERE
							acl = orig_acl
					)
			) as foo
	) AS rdefaclacl,
	NULL AS initdefaclacl,
	NULL AS initrdefaclacl
FROM
	pg_default_acl d
	LEFT JOIN pg_init_privs pip ON (
		d.oid = pip.objoid
		AND pip.classoid = 'pg_default_acl' :: regclass
		AND pip.objsubid = 0
	);

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16805' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16808' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16813' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16818' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16823' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16828' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16833' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16838' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16841' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16845' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16849' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16853' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	a.attnum,
	a.attname,
	a.atttypmod,
	a.attstattarget,
	a.attstorage,
	t.typstorage,
	a.attnotnull,
	a.atthasdef,
	a.attisdropped,
	a.attlen,
	a.attalign,
	a.attislocal,
	pg_catalog.format_type(t.oid, a.atttypmod) AS atttypname,
	array_to_string(a.attoptions, ', ') AS attoptions,
	CASE
		WHEN a.attcollation <> t.typcollation THEN a.attcollation
		ELSE 0
	END AS attcollation,
	a.attidentity,
	pg_catalog.array_to_string(
		ARRAY(
			SELECT
				pg_catalog.quote_ident(option_name) || ' ' || pg_catalog.quote_literal(option_value)
			FROM
				pg_catalog.pg_options_to_table(attfdwoptions)
			ORDER BY
				option_name
		),
		E',\n'
	) AS attfdwoptions,
	CASE
		WHEN a.atthasmissing
		AND NOT a.attisdropped THEN a.attmissingval
		ELSE null
	END AS attmissingval
FROM
	pg_catalog.pg_attribute a
	LEFT JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
WHERE
	a.attrelid = '16859' :: pg_catalog.oid
	AND a.attnum > 0 :: pg_catalog.int2
ORDER BY
	a.attnum;

SELECT
	t.tableoid,
	t.oid,
	t.relname AS indexname,
	inh.inhparent AS parentidx,
	pg_catalog.pg_get_indexdef(i.indexrelid) AS indexdef,
	i.indnkeyatts AS indnkeyatts,
	i.indnatts AS indnatts,
	i.indkey,
	i.indisclustered,
	i.indisreplident,
	i.indoption,
	t.relpages,
	c.contype,
	c.conname,
	c.condeferrable,
	c.condeferred,
	c.tableoid AS contableoid,
	c.oid AS conoid,
	pg_catalog.pg_get_constraintdef(c.oid, false) AS condef,
	(
		SELECT
			spcname
		FROM
			pg_catalog.pg_tablespace s
		WHERE
			s.oid = t.reltablespace
	) AS tablespace,
	t.reloptions AS indreloptions,
	(
		SELECT
			pg_catalog.array_agg(
				attnum
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatcols,
	(
		SELECT
			pg_catalog.array_agg(
				attstattarget
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatvals
FROM
	pg_catalog.pg_index i
	JOIN pg_catalog.pg_class t ON (t.oid = i.indexrelid)
	JOIN pg_catalog.pg_class t2 ON (t2.oid = i.indrelid)
	LEFT JOIN pg_catalog.pg_constraint c ON (
		i.indrelid = c.conrelid
		AND i.indexrelid = c.conindid
		AND c.contype IN ('p', 'u', 'x')
	)
	LEFT JOIN pg_catalog.pg_inherits inh ON (inh.inhrelid = indexrelid)
WHERE
	i.indrelid = '16808' :: pg_catalog.oid
	AND (
		i.indisvalid
		OR t2.relkind = 'p'
	)
	AND i.indisready
ORDER BY
	indexname;

SELECT
	t.tableoid,
	t.oid,
	t.relname AS indexname,
	inh.inhparent AS parentidx,
	pg_catalog.pg_get_indexdef(i.indexrelid) AS indexdef,
	i.indnkeyatts AS indnkeyatts,
	i.indnatts AS indnatts,
	i.indkey,
	i.indisclustered,
	i.indisreplident,
	i.indoption,
	t.relpages,
	c.contype,
	c.conname,
	c.condeferrable,
	c.condeferred,
	c.tableoid AS contableoid,
	c.oid AS conoid,
	pg_catalog.pg_get_constraintdef(c.oid, false) AS condef,
	(
		SELECT
			spcname
		FROM
			pg_catalog.pg_tablespace s
		WHERE
			s.oid = t.reltablespace
	) AS tablespace,
	t.reloptions AS indreloptions,
	(
		SELECT
			pg_catalog.array_agg(
				attnum
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatcols,
	(
		SELECT
			pg_catalog.array_agg(
				attstattarget
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatvals
FROM
	pg_catalog.pg_index i
	JOIN pg_catalog.pg_class t ON (t.oid = i.indexrelid)
	JOIN pg_catalog.pg_class t2 ON (t2.oid = i.indrelid)
	LEFT JOIN pg_catalog.pg_constraint c ON (
		i.indrelid = c.conrelid
		AND i.indexrelid = c.conindid
		AND c.contype IN ('p', 'u', 'x')
	)
	LEFT JOIN pg_catalog.pg_inherits inh ON (inh.inhrelid = indexrelid)
WHERE
	i.indrelid = '16813' :: pg_catalog.oid
	AND (
		i.indisvalid
		OR t2.relkind = 'p'
	)
	AND i.indisready
ORDER BY
	indexname;

SELECT
	t.tableoid,
	t.oid,
	t.relname AS indexname,
	inh.inhparent AS parentidx,
	pg_catalog.pg_get_indexdef(i.indexrelid) AS indexdef,
	i.indnkeyatts AS indnkeyatts,
	i.indnatts AS indnatts,
	i.indkey,
	i.indisclustered,
	i.indisreplident,
	i.indoption,
	t.relpages,
	c.contype,
	c.conname,
	c.condeferrable,
	c.condeferred,
	c.tableoid AS contableoid,
	c.oid AS conoid,
	pg_catalog.pg_get_constraintdef(c.oid, false) AS condef,
	(
		SELECT
			spcname
		FROM
			pg_catalog.pg_tablespace s
		WHERE
			s.oid = t.reltablespace
	) AS tablespace,
	t.reloptions AS indreloptions,
	(
		SELECT
			pg_catalog.array_agg(
				attnum
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatcols,
	(
		SELECT
			pg_catalog.array_agg(
				attstattarget
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatvals
FROM
	pg_catalog.pg_index i
	JOIN pg_catalog.pg_class t ON (t.oid = i.indexrelid)
	JOIN pg_catalog.pg_class t2 ON (t2.oid = i.indrelid)
	LEFT JOIN pg_catalog.pg_constraint c ON (
		i.indrelid = c.conrelid
		AND i.indexrelid = c.conindid
		AND c.contype IN ('p', 'u', 'x')
	)
	LEFT JOIN pg_catalog.pg_inherits inh ON (inh.inhrelid = indexrelid)
WHERE
	i.indrelid = '16818' :: pg_catalog.oid
	AND (
		i.indisvalid
		OR t2.relkind = 'p'
	)
	AND i.indisready
ORDER BY
	indexname;

SELECT
	t.tableoid,
	t.oid,
	t.relname AS indexname,
	inh.inhparent AS parentidx,
	pg_catalog.pg_get_indexdef(i.indexrelid) AS indexdef,
	i.indnkeyatts AS indnkeyatts,
	i.indnatts AS indnatts,
	i.indkey,
	i.indisclustered,
	i.indisreplident,
	i.indoption,
	t.relpages,
	c.contype,
	c.conname,
	c.condeferrable,
	c.condeferred,
	c.tableoid AS contableoid,
	c.oid AS conoid,
	pg_catalog.pg_get_constraintdef(c.oid, false) AS condef,
	(
		SELECT
			spcname
		FROM
			pg_catalog.pg_tablespace s
		WHERE
			s.oid = t.reltablespace
	) AS tablespace,
	t.reloptions AS indreloptions,
	(
		SELECT
			pg_catalog.array_agg(
				attnum
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatcols,
	(
		SELECT
			pg_catalog.array_agg(
				attstattarget
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatvals
FROM
	pg_catalog.pg_index i
	JOIN pg_catalog.pg_class t ON (t.oid = i.indexrelid)
	JOIN pg_catalog.pg_class t2 ON (t2.oid = i.indrelid)
	LEFT JOIN pg_catalog.pg_constraint c ON (
		i.indrelid = c.conrelid
		AND i.indexrelid = c.conindid
		AND c.contype IN ('p', 'u', 'x')
	)
	LEFT JOIN pg_catalog.pg_inherits inh ON (inh.inhrelid = indexrelid)
WHERE
	i.indrelid = '16823' :: pg_catalog.oid
	AND (
		i.indisvalid
		OR t2.relkind = 'p'
	)
	AND i.indisready
ORDER BY
	indexname;

SELECT
	t.tableoid,
	t.oid,
	t.relname AS indexname,
	inh.inhparent AS parentidx,
	pg_catalog.pg_get_indexdef(i.indexrelid) AS indexdef,
	i.indnkeyatts AS indnkeyatts,
	i.indnatts AS indnatts,
	i.indkey,
	i.indisclustered,
	i.indisreplident,
	i.indoption,
	t.relpages,
	c.contype,
	c.conname,
	c.condeferrable,
	c.condeferred,
	c.tableoid AS contableoid,
	c.oid AS conoid,
	pg_catalog.pg_get_constraintdef(c.oid, false) AS condef,
	(
		SELECT
			spcname
		FROM
			pg_catalog.pg_tablespace s
		WHERE
			s.oid = t.reltablespace
	) AS tablespace,
	t.reloptions AS indreloptions,
	(
		SELECT
			pg_catalog.array_agg(
				attnum
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatcols,
	(
		SELECT
			pg_catalog.array_agg(
				attstattarget
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatvals
FROM
	pg_catalog.pg_index i
	JOIN pg_catalog.pg_class t ON (t.oid = i.indexrelid)
	JOIN pg_catalog.pg_class t2 ON (t2.oid = i.indrelid)
	LEFT JOIN pg_catalog.pg_constraint c ON (
		i.indrelid = c.conrelid
		AND i.indexrelid = c.conindid
		AND c.contype IN ('p', 'u', 'x')
	)
	LEFT JOIN pg_catalog.pg_inherits inh ON (inh.inhrelid = indexrelid)
WHERE
	i.indrelid = '16828' :: pg_catalog.oid
	AND (
		i.indisvalid
		OR t2.relkind = 'p'
	)
	AND i.indisready
ORDER BY
	indexname;

SELECT
	t.tableoid,
	t.oid,
	t.relname AS indexname,
	inh.inhparent AS parentidx,
	pg_catalog.pg_get_indexdef(i.indexrelid) AS indexdef,
	i.indnkeyatts AS indnkeyatts,
	i.indnatts AS indnatts,
	i.indkey,
	i.indisclustered,
	i.indisreplident,
	i.indoption,
	t.relpages,
	c.contype,
	c.conname,
	c.condeferrable,
	c.condeferred,
	c.tableoid AS contableoid,
	c.oid AS conoid,
	pg_catalog.pg_get_constraintdef(c.oid, false) AS condef,
	(
		SELECT
			spcname
		FROM
			pg_catalog.pg_tablespace s
		WHERE
			s.oid = t.reltablespace
	) AS tablespace,
	t.reloptions AS indreloptions,
	(
		SELECT
			pg_catalog.array_agg(
				attnum
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatcols,
	(
		SELECT
			pg_catalog.array_agg(
				attstattarget
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatvals
FROM
	pg_catalog.pg_index i
	JOIN pg_catalog.pg_class t ON (t.oid = i.indexrelid)
	JOIN pg_catalog.pg_class t2 ON (t2.oid = i.indrelid)
	LEFT JOIN pg_catalog.pg_constraint c ON (
		i.indrelid = c.conrelid
		AND i.indexrelid = c.conindid
		AND c.contype IN ('p', 'u', 'x')
	)
	LEFT JOIN pg_catalog.pg_inherits inh ON (inh.inhrelid = indexrelid)
WHERE
	i.indrelid = '16833' :: pg_catalog.oid
	AND (
		i.indisvalid
		OR t2.relkind = 'p'
	)
	AND i.indisready
ORDER BY
	indexname;

SELECT
	t.tableoid,
	t.oid,
	t.relname AS indexname,
	inh.inhparent AS parentidx,
	pg_catalog.pg_get_indexdef(i.indexrelid) AS indexdef,
	i.indnkeyatts AS indnkeyatts,
	i.indnatts AS indnatts,
	i.indkey,
	i.indisclustered,
	i.indisreplident,
	i.indoption,
	t.relpages,
	c.contype,
	c.conname,
	c.condeferrable,
	c.condeferred,
	c.tableoid AS contableoid,
	c.oid AS conoid,
	pg_catalog.pg_get_constraintdef(c.oid, false) AS condef,
	(
		SELECT
			spcname
		FROM
			pg_catalog.pg_tablespace s
		WHERE
			s.oid = t.reltablespace
	) AS tablespace,
	t.reloptions AS indreloptions,
	(
		SELECT
			pg_catalog.array_agg(
				attnum
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatcols,
	(
		SELECT
			pg_catalog.array_agg(
				attstattarget
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatvals
FROM
	pg_catalog.pg_index i
	JOIN pg_catalog.pg_class t ON (t.oid = i.indexrelid)
	JOIN pg_catalog.pg_class t2 ON (t2.oid = i.indrelid)
	LEFT JOIN pg_catalog.pg_constraint c ON (
		i.indrelid = c.conrelid
		AND i.indexrelid = c.conindid
		AND c.contype IN ('p', 'u', 'x')
	)
	LEFT JOIN pg_catalog.pg_inherits inh ON (inh.inhrelid = indexrelid)
WHERE
	i.indrelid = '16838' :: pg_catalog.oid
	AND (
		i.indisvalid
		OR t2.relkind = 'p'
	)
	AND i.indisready
ORDER BY
	indexname;

SELECT
	t.tableoid,
	t.oid,
	t.relname AS indexname,
	inh.inhparent AS parentidx,
	pg_catalog.pg_get_indexdef(i.indexrelid) AS indexdef,
	i.indnkeyatts AS indnkeyatts,
	i.indnatts AS indnatts,
	i.indkey,
	i.indisclustered,
	i.indisreplident,
	i.indoption,
	t.relpages,
	c.contype,
	c.conname,
	c.condeferrable,
	c.condeferred,
	c.tableoid AS contableoid,
	c.oid AS conoid,
	pg_catalog.pg_get_constraintdef(c.oid, false) AS condef,
	(
		SELECT
			spcname
		FROM
			pg_catalog.pg_tablespace s
		WHERE
			s.oid = t.reltablespace
	) AS tablespace,
	t.reloptions AS indreloptions,
	(
		SELECT
			pg_catalog.array_agg(
				attnum
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatcols,
	(
		SELECT
			pg_catalog.array_agg(
				attstattarget
				ORDER BY
					attnum
			)
		FROM
			pg_catalog.pg_attribute
		WHERE
			attrelid = i.indexrelid
			AND attstattarget >= 0
	) AS indstatvals
FROM
	pg_catalog.pg_index i
	JOIN pg_catalog.pg_class t ON (t.oid = i.indexrelid)
	JOIN pg_catalog.pg_class t2 ON (t2.oid = i.indrelid)
	LEFT JOIN pg_catalog.pg_constraint c ON (
		i.indrelid = c.conrelid
		AND i.indexrelid = c.conindid
		AND c.contype IN ('p', 'u', 'x')
	)
	LEFT JOIN pg_catalog.pg_inherits inh ON (inh.inhrelid = indexrelid)
WHERE
	i.indrelid = '16859' :: pg_catalog.oid
	AND (
		i.indisvalid
		OR t2.relkind = 'p'
	)
	AND i.indisready
ORDER BY
	indexname;

SELECT
	tableoid,
	oid,
	stxname,
	stxnamespace,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = stxowner
	) AS rolname
FROM
	pg_catalog.pg_statistic_ext;

SELECT
	tableoid,
	oid,
	rulename,
	ev_class AS ruletable,
	ev_type,
	is_instead,
	ev_enabled
FROM
	pg_rewrite
ORDER BY
	oid;

SELECT
	oid,
	tableoid,
	pol.polrelid,
	pol.polname,
	pol.polcmd,
	pol.polpermissive,
	CASE
		WHEN pol.polroles = '{0}' THEN NULL
		ELSE pg_catalog.array_to_string(
			ARRAY(
				SELECT
					pg_catalog.quote_ident(rolname)
				from
					pg_catalog.pg_roles
				WHERE
					oid = ANY(pol.polroles)
			),
			', '
		)
	END AS polroles,
	pg_catalog.pg_get_expr(pol.polqual, pol.polrelid) AS polqual,
	pg_catalog.pg_get_expr(pol.polwithcheck, pol.polrelid) AS polwithcheck
FROM
	pg_catalog.pg_policy pol;

WITH RECURSIVE w AS (
		SELECT
			d1.objid,
			d2.refobjid,
			c2.relkind AS refrelkind
		FROM
			pg_depend d1
			JOIN pg_class c1 ON c1.oid = d1.objid
			AND c1.relkind = 'm'
			JOIN pg_rewrite r1 ON r1.ev_class = d1.objid
			JOIN pg_depend d2 ON d2.classid = 'pg_rewrite' :: regclass
			AND d2.objid = r1.oid
			AND d2.refobjid <> d1.objid
			JOIN pg_class c2 ON c2.oid = d2.refobjid
			AND c2.relkind IN ('m', 'v')
		WHERE
			d1.classid = 'pg_class' :: regclass
		UNION
		SELECT
			w.objid,
			d3.refobjid,
			c3.relkind
		FROM
			w
			JOIN pg_rewrite r3 ON r3.ev_class = w.refobjid
			JOIN pg_depend d3 ON d3.classid = 'pg_rewrite' :: regclass
			AND d3.objid = r3.oid
			AND d3.refobjid <> w.refobjid
			JOIN pg_class c3 ON c3.oid = d3.refobjid
			AND c3.relkind IN ('m', 'v')
	)
SELECT
	'pg_class' :: regclass :: oid AS classid,
	objid,
	refobjid
FROM
	w
WHERE
	refrelkind = 'm';

SELECT
	l.oid,
	(
		SELECT
			rolname
		FROM
			pg_catalog.pg_roles
		WHERE
			oid = l.lomowner
	) AS rolname,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(l.lomacl, pg_catalog.acldefault('L', l.lomowner))
					) WITH ORDINALITY AS perm(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(
									pip.initprivs,
									pg_catalog.acldefault('L', l.lomowner)
								)
							) AS init(init_acl)
						WHERE
							acl = init_acl
					)
			) as foo
	) AS lomacl,
	(
		SELECT
			pg_catalog.array_agg(
				acl
				ORDER BY
					row_n
			)
		FROM
			(
				SELECT
					acl,
					row_n
				FROM
					pg_catalog.unnest(
						coalesce(
							pip.initprivs,
							pg_catalog.acldefault('L', l.lomowner)
						)
					) WITH ORDINALITY AS initp(acl, row_n)
				WHERE
					NOT EXISTS (
						SELECT
							1
						FROM
							pg_catalog.unnest(
								coalesce(l.lomacl, pg_catalog.acldefault('L', l.lomowner))
							) AS permp(orig_acl)
						WHERE
							acl = orig_acl
					)
			) as foo
	) AS rlomacl,
	NULL AS initlomacl,
	NULL AS initrlomacl
FROM
	pg_largeobject_metadata l
	LEFT JOIN pg_init_privs pip ON (
		l.oid = pip.objoid
		AND pip.classoid = 'pg_largeobject' :: regclass
		AND pip.objsubid = 0
	);
