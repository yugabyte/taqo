SELECT * FROM
	(SELECT pg_catalog.pg_encoding_to_char(s.i) AS encoding
	FROM (SELECT pg_catalog.generate_series(0, 100, 1) as i) s) a
	WHERE encoding != '' ORDER BY encoding;
