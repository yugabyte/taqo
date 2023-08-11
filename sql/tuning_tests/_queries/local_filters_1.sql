create function ident(i int)
   returns int 
   language plpgsql
  as
$$
declare 
begin
 return i;
end;
$$;

SELECT * FROM t_range_100k WHERE v2 > ident(50000);
SELECT * FROM t_range_200k WHERE v2 > ident(150000);
SELECT * FROM t_range_300k WHERE v2 > ident(250000);
SELECT * FROM t_range_400k WHERE v2 > ident(350000);
SELECT * FROM t_range_500k WHERE v2 > ident(450000);
SELECT * FROM t_range_600k WHERE v2 > ident(550000);
SELECT * FROM t_range_700k WHERE v2 > ident(650000);
SELECT * FROM t_range_800k WHERE v2 > ident(750000);
SELECT * FROM t_range_900k WHERE v2 > ident(850000);
SELECT * FROM t_range_1m WHERE v2 > ident(950000);