-- nested conditions (each of the module conditions are valid for remote pushdown)

-- first, try a series of increasingly large selects.
-- as the proportion of rows selected increases, sequential scan should be favoured
select * from t100 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select * from t1000 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select * from t10000 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select * from t100000 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select * from t100000w where c1 < 10 OR (c2 < 10 AND c3 < 10);
select * from t1000000m where c1 < 10 OR (c2 < 10 AND c3 < 10);

select * from t100 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select * from t1000 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select * from t10000 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select * from t100000 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select * from t100000w where c1 < 100 OR (c2 < 100 AND c3 < 100);
select * from t1000000m where c1 < 100 OR (c2 < 100 AND c3 < 100);

select * from t100 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select * from t1000 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select * from t10000 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select * from t100000 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select * from t100000w where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select * from t1000000m where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);

select * from t100 where c1 < 10000 OR (c2 < 10000 AND c3 < 10000);
select * from t1000 where c1 < 10000 OR (c2 < 10000 AND c3 < 10000);
select * from t10000 where c1 < 10000 OR (c2 < 10000 AND c3 < 10000);
select * from t100000 where c1 < 10000 OR (c2 < 10000 AND c3 < 10000);
select * from t100000w where c1 < 10000 OR (c2 < 10000 AND c3 < 10000);
select * from t1000000m where c1 < 10000 OR (c2 < 10000 AND c3 < 10000);

-- queries with IS NULL
select * from t100 where c1 < 1000 OR c6 IS NULL;
select * from t1000 where c1 < 1000 OR c6 IS NULL;
select * from t10000 where c1 < 1000 OR c6 IS NULL;
select * from t100000 where c1 < 1000 OR c6 IS NULL;
select * from t100000w where c1 < 1000 OR c6 IS NULL;
select * from t1000000m where c1 < 1000 OR c6 IS NULL;

select * from t100 where c1 < 1000 AND c6 IS NULL;
select * from t1000 where c1 < 1000 AND c6 IS NULL;
select * from t10000 where c1 < 1000 AND c6 IS NULL;
select * from t100000 where c1 < 1000 AND c6 IS NULL;
select * from t100000w where c1 < 1000 AND c6 IS NULL;
select * from t1000000m where c1 < 1000 AND c6 IS NULL;

select * from t100 where c1 < 1000 OR (c2 < 1000 AND c6 IS NULL);
select * from t1000 where c1 < 1000 OR (c2 < 1000 AND c6 IS NULL);
select * from t10000 where c1 < 1000 OR (c2 < 1000 AND c6 IS NULL);
select * from t100000 where c1 < 1000 OR (c2 < 1000 AND c6 IS NULL);
select * from t100000w where c1 < 1000 OR (c2 < 1000 AND c6 IS NULL);
select * from t1000000m where c1 < 1000 OR (c2 < 1000 AND c6 IS NULL);

-- try some different shapes of differing sizes
select * from t100 where c1 < 100 OR c2 < 100 OR c4 < 100 OR c3 < 100;
select * from t1000 where c1 < 100 OR c2 < 100 OR c4 < 100 OR c3 < 100;
select * from t10000 where c1 < 100 OR c2 < 100 OR c4 < 100 OR c3 < 100;
select * from t100000 where c1 < 100 OR c2 < 100 OR c4 < 100 OR c3 < 100;
select * from t100000w where c1 < 100 OR c2 < 100 OR c4 < 100 OR c3 < 100;
select * from t1000000m where c1 < 100 OR c2 < 100 OR c4 < 100 OR c3 < 100;

select * from t100 where c1 < 100 OR ((c2 < 100 OR c4 < 100) AND c3 < 100);
select * from t1000 where c1 < 100 OR ((c2 < 100 OR c4 < 100) AND c3 < 100);
select * from t10000 where c1 < 100 OR ((c2 < 100 OR c4 < 100) AND c3 < 100);
select * from t100000 where c1 < 100 OR ((c2 < 100 OR c4 < 100) AND c3 < 100);
select * from t100000w where c1 < 100 OR ((c2 < 100 OR c4 < 100) AND c3 < 100);
select * from t1000000m where c1 < 100 OR ((c2 < 100 OR c4 < 100) AND c3 < 100);

select * from t100 where c1 < 1000 OR ((c2 < 1000 OR c4 < 100) AND c3 < 1000);
select * from t1000 where c1 < 1000 OR ((c2 < 1000 OR c4 < 100) AND c3 < 1000);
select * from t10000 where c1 < 1000 OR ((c2 < 1000 OR c4 < 100) AND c3 < 1000);
select * from t100000 where c1 < 1000 OR ((c2 < 1000 OR c4 < 100) AND c3 < 1000);
select * from t100000w where c1 < 1000 OR ((c2 < 1000 OR c4 < 100) AND c3 < 1000);
select * from t1000000m where c1 < 1000 OR ((c2 < 1000 OR c4 < 100) AND c3 < 1000);

select * from t100 where c1 < 1000 OR ((c2 < 1000 OR c4 < 1000) AND c3 < 1000);
select * from t1000 where c1 < 1000 OR ((c2 < 1000 OR c4 < 1000) AND c3 < 1000);
select * from t10000 where c1 < 1000 OR ((c2 < 1000 OR c4 < 1000) AND c3 < 1000);
select * from t100000 where c1 < 1000 OR ((c2 < 1000 OR c4 < 1000) AND c3 < 1000);
select * from t100000w where c1 < 1000 OR ((c2 < 1000 OR c4 < 1000) AND c3 < 1000);
select * from t1000000m where c1 < 1000 OR ((c2 < 1000 OR c4 < 1000) AND c3 < 1000);

-- test some queries that could allow for remote filter pushdown
select * from t100 where c1 < 1000 OR (c2 < 1000 AND c2 % 2 = 0 AND c3 < 1000 AND c3 % 2 = 0);
select * from t1000 where c1 < 1000 OR (c2 < 1000 AND c2 % 2 = 0 AND c3 < 1000 AND c3 % 2 = 0);
select * from t10000 where c1 < 1000 OR (c2 < 1000 AND c2 % 2 = 0 AND c3 < 1000 AND c3 % 2 = 0);
select * from t100000 where c1 < 1000 OR (c2 < 1000 AND c2 % 2 = 0 AND c3 < 1000 AND c3 % 2 = 0);
select * from t100000w where c1 < 1000 OR (c2 < 1000 AND c2 % 2 = 0 AND c3 < 1000 AND c3 % 2 = 0);
select * from t1000000m where c1 < 1000 OR (c2 < 1000 AND c2 % 2 = 0 AND c3 < 1000 AND c3 % 2 = 0);

select * from t100 where (c1 < 100 AND c2 % 2 = 0) OR ((c2 < 100 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 100 AND c3 % 2 = 0));
select * from t1000 where (c1 < 100 AND c2 % 2 = 0) OR ((c2 < 100 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 100 AND c3 % 2 = 0));
select * from t10000 where (c1 < 100 AND c2 % 2 = 0) OR ((c2 < 100 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 100 AND c3 % 2 = 0));
select * from t100000 where (c1 < 100 AND c2 % 2 = 0) OR ((c2 < 100 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 100 AND c3 % 2 = 0));
select * from t100000w where (c1 < 100 AND c2 % 2 = 0) OR ((c2 < 100 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 100 AND c3 % 2 = 0));
select * from t1000000m where (c1 < 100 AND c2 % 2 = 0) OR ((c2 < 100 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 100 AND c3 % 2 = 0));

select * from t100 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select * from t1000 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select * from t10000 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select * from t100000 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select * from t100000w where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select * from t1000000m where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));

select * from t100 where (c1 < 100 AND c1 % 2 = 0) OR (c2 < 100 AND c2 % 2 = 0) OR (c4 < 100 AND c4 % 2 = 0);
select * from t1000 where (c1 < 100 AND c1 % 2 = 0) OR (c2 < 100 AND c2 % 2 = 0) OR (c4 < 100 AND c4 % 2 = 0);
select * from t10000 where (c1 < 100 AND c1 % 2 = 0) OR (c2 < 100 AND c2 % 2 = 0) OR (c4 < 100 AND c4 % 2 = 0);
select * from t100000 where (c1 < 100 AND c1 % 2 = 0) OR (c2 < 100 AND c2 % 2 = 0) OR (c4 < 100 AND c4 % 2 = 0);
select * from t100000w where (c1 < 100 AND c1 % 2 = 0) OR (c2 < 100 AND c2 % 2 = 0) OR (c4 < 100 AND c4 % 2 = 0);
select * from t1000000m where (c1 < 100 AND c1 % 2 = 0) OR (c2 < 100 AND c2 % 2 = 0) OR (c4 < 100 AND c4 % 2 = 0);

-- these queries should use an index only scan
select c2, c4 from t100 where c2 < 10 AND c4 < 10;
select c2, c4 from t1000 where c2 < 10 AND c4 < 10;
select c2, c4 from t10000 where c2 < 10 AND c4 < 10;
select c2, c4 from t100000 where c2 < 10 AND c4 < 10;
select c2, c4 from t100000w where c2 < 10 AND c4 < 10;
select c2, c4 from t1000000m where c2 < 10 AND c4 < 10;

select c2, c4 from t100 where c2 < 100 AND c4 < 100;
select c2, c4 from t1000 where c2 < 100 AND c4 < 100;
select c2, c4 from t10000 where c2 < 100 AND c4 < 100;
select c2, c4 from t100000 where c2 < 100 AND c4 < 100;
select c2, c4 from t100000w where c2 < 100 AND c4 < 100;
select c2, c4 from t1000000m where c2 < 100 AND c4 < 100;

select c2, c4 from t100 where c2 < 1000 AND c4 < 1000;
select c2, c4 from t1000 where c2 < 1000 AND c4 < 1000;
select c2, c4 from t10000 where c2 < 1000 AND c4 < 1000;
select c2, c4 from t100000 where c2 < 1000 AND c4 < 1000;
select c2, c4 from t100000w where c2 < 1000 AND c4 < 1000;
select c2, c4 from t1000000m where c2 < 1000 AND c4 < 1000;

-- these queries should use an index scan
select * from t100 where c2 < 10 AND c4 < 10;
select * from t1000 where c2 < 10 AND c4 < 10;
select * from t10000 where c2 < 10 AND c4 < 10;
select * from t100000 where c2 < 10 AND c4 < 10;
select * from t100000w where c2 < 10 AND c4 < 10;
select * from t1000000m where c2 < 10 AND c4 < 10;

select * from t100 where c2 < 100 AND c4 < 100;
select * from t1000 where c2 < 100 AND c4 < 100;
select * from t10000 where c2 < 100 AND c4 < 100;
select * from t100000 where c2 < 100 AND c4 < 100;
select * from t100000w where c2 < 100 AND c4 < 100;
select * from t1000000m where c2 < 100 AND c4 < 100;

select * from t100 where c2 < 1000 AND c4 < 1000;
select * from t1000 where c2 < 1000 AND c4 < 1000;
select * from t10000 where c2 < 1000 AND c4 < 1000;
select * from t100000 where c2 < 1000 AND c4 < 1000;
select * from t100000w where c2 < 1000 AND c4 < 1000;
select * from t1000000m where c2 < 1000 AND c4 < 1000;

-- count
select count(*) from t100 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select count(*) from t1000 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select count(*) from t10000 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select count(*) from t100000 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select count(*) from t100000w where c1 < 10 OR (c2 < 10 AND c3 < 10);
select count(*) from t1000000m where c1 < 10 OR (c2 < 10 AND c3 < 10);

select count(*) from t100 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select count(*) from t1000 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select count(*) from t10000 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select count(*) from t100000 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select count(*) from t100000w where c1 < 100 OR (c2 < 100 AND c3 < 100);
select count(*) from t1000000m where c1 < 100 OR (c2 < 100 AND c3 < 100);

select count(*) from t100 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select count(*) from t1000 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select count(*) from t10000 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select count(*) from t100000 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select count(*) from t100000w where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select count(*) from t1000000m where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);

select count(*) from t100 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select count(*) from t1000 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select count(*) from t10000 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select count(*) from t100000 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select count(*) from t100000w where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select count(*) from t1000000m where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));

-- max (these queries have conditions that might help to find the min, but not the max)
select max(c2) from t100 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select max(c2) from t1000 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select max(c2) from t10000 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select max(c2) from t100000 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select max(c2) from t100000w where c1 < 100 OR (c2 < 100 AND c3 < 100);
select max(c2) from t1000000m where c1 < 100 OR (c2 < 100 AND c3 < 100);

select max(c2) from t100 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select max(c2) from t1000 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select max(c2) from t10000 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select max(c2) from t100000 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select max(c2) from t100000w where c1 < 10 OR (c2 < 10 AND c3 < 10);
select max(c2) from t1000000m where c1 < 10 OR (c2 < 10 AND c3 < 10);

select max(c2) from t100 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select max(c2) from t1000 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select max(c2) from t10000 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select max(c2) from t100000 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select max(c2) from t100000w where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select max(c2) from t1000000m where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);

select max(c2) from t100 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select max(c2) from t1000 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select max(c2) from t10000 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select max(c2) from t100000 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select max(c2) from t100000w where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select max(c2) from t1000000m where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));

-- sum
select sum(c2) from t100 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select sum(c2) from t1000 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select sum(c2) from t10000 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select sum(c2) from t100000 where c1 < 100 OR (c2 < 100 AND c3 < 100);
select sum(c2) from t100000w where c1 < 100 OR (c2 < 100 AND c3 < 100);
select sum(c2) from t1000000m where c1 < 100 OR (c2 < 100 AND c3 < 100);

select sum(c2) from t100 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select sum(c2) from t1000 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select sum(c2) from t10000 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select sum(c2) from t100000 where c1 < 10 OR (c2 < 10 AND c3 < 10);
select sum(c2) from t100000w where c1 < 10 OR (c2 < 10 AND c3 < 10);
select sum(c2) from t1000000m where c1 < 10 OR (c2 < 10 AND c3 < 10);

select sum(c2) from t100 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select sum(c2) from t1000 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select sum(c2) from t10000 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select sum(c2) from t100000 where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select sum(c2) from t100000w where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);
select sum(c2) from t1000000m where c1 < 1000 OR (c2 < 1000 AND c3 < 1000);

select sum(c2) from t100 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select sum(c2) from t1000 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select sum(c2) from t10000 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select sum(c2) from t100000 where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select sum(c2) from t100000w where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
select sum(c2) from t1000000m where (c1 < 1000 AND c2 % 2 = 0) OR ((c2 < 1000 OR (c4 < 100 AND c4 % 2 = 0)) AND (c3 < 1000 AND c3 % 2 = 0));
