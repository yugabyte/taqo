SELECT B'1010' AS b1,
       X'1F' AS x1,
       B'1010' | B'0101' AS bor,
       bit '11' AS b2,
       '101'::bit(3) AS b3,
       '1'::bit AS b4,
       '1010'::bit varying(8) AS b5,
       '10'::varbit AS b6;

SELECT bpchar(5) 'ab' AS fn_const,
       numeric '3.14' AS num_const,
       numeric(5, 1) '2.25' AS num_mod_const,
       decimal '1.5' AS dec_const,
       char 'z' AS ch_const,
       varchar(3) 'abcdef' AS vc_const,
       int '42' AS int_const,
       boolean 'yes' AS bool_const,
       real '1.5' AS real_const,
       float '2.5' AS float_const,
       double precision '1e10' AS dbl_const;

SELECT timestamp '2024-02-29 12:00:00' AS ts,
       timestamp(0) '2024-02-29 12:00:00.789' AS ts0,
       timestamp(3) with time zone '2024-02-29 12:00:00.123456+00' AS tstz3,
       timestamp without time zone '2024-01-01' AS ts_wo,
       timestamp with time zone '2024-01-01 00:00:00+00' AS tstz,
       time '10:11:12' AS t,
       time(2) '10:11:12.345' AS t2,
       time with time zone '10:11:12+03' AS ttz,
       time (1) without time zone '01:02:03.45' AS t1wo,
       date '2024-12-31' AS d;

SELECT interval '1 day' AS i,
       interval '3' year AS iy,
       interval '7' month AS imo,
       interval '2' day AS id,
       interval '5' hour AS ih,
       interval '30' minute AS imi,
       interval '45' second AS isec,
       interval '1.123456' second(3) AS isec3,
       interval '1-2' year to month AS iym,
       interval '3 4' day to hour AS idh,
       interval '3 4:05' day to minute AS idm,
       interval '3 4:05:06.7' day to second AS ids,
       interval '4:05' hour to minute AS ihm,
       interval '4:05:06' hour to second AS ihs,
       interval '05:06.789' minute to second(2) AS ims,
       interval(2) '1.2345 seconds' AS iprec;

SELECT c_int::dec(10, 2) AS d1,
       c_int::decimal AS d2,
       c_int::float(10) AS f1,
       c_int::float(40) AS f2,
       c_int::double precision AS f3,
       c_int::real AS f4,
       c_int::smallint AS s1,
       c_int::bigint AS s2,
       c_int::integer AS s3,
       c_int::boolean AS bo,
       c_text::national character varying(20) AS nv1,
       c_text::national char(12) AS nc,
       c_text::nchar varying(10) AS nv2,
       c_text::char varying(8) AS cv,
       c_text::character(12) AS ch,
       c_ts::timestamp(2) without time zone AS ts2,
       '10:00:00+02'::time with time zone AS ttz,
       c_ts::time(0) AS t0,
       c_int::bit(16) AS bits,
       c_int::bit(32)::bit varying(32) AS vbits
FROM lmc_main
WHERE c_int < 4
ORDER BY c_int;

SELECT CAST(c_arr AS int ARRAY) AS a1,
       CAST(c_arr AS int ARRAY[3]) AS a2,
       c_arr::bigint[][] AS a3,
       c_arr::int[3][3] AS a4,
       c_arr::text[] AS a5,
       '{1,2}'::smallint[] AS a6
FROM lmc_main
WHERE c_int < 3
ORDER BY c_int;

SELECT '2024-01-01'::date + interval '1' month AS plus_month,
       '12:00'::time - interval '90' minute AS minus_min,
       now()::date - '2024-01-01'::date >= 0 AS sane,
       '1 week'::interval hour AS ih,
       '100'::interval minute to second AS ims;
