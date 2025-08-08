-- projection
select                 c4                     from t1000000c10;
select                     c5                 from t1000000c10;
select                 c4, c5                 from t1000000c10;
select             c3, c4, c5                 from t1000000c10;
select                 c4, c5, c6             from t1000000c10;
select             c3, c4, c5, c6             from t1000000c10;
select         c2, c3, c4, c5, c6             from t1000000c10;
select             c3, c4, c5, c6, c7         from t1000000c10;
select         c2, c3, c4, c5, c6, c7         from t1000000c10;
select     c1, c2, c3, c4, c5, c6, c7         from t1000000c10;
select         c2, c3, c4, c5, c6, c7, c8     from t1000000c10;
select     c1, c2, c3, c4, c5, c6, c7, c8     from t1000000c10;
select c0, c1, c2, c3, c4, c5, c6, c7, c8     from t1000000c10;
select     c1, c2, c3, c4, c5, c6, c7, c8, c9 from t1000000c10;
select c0, c1, c2, c3, c4, c5, c6, c7, c8, c9 from t1000000c10;

select c0 from t1000000c01;
select c0, c1 from t1000000c02;
select c0, c1, c2 from t1000000c03;
select c0, c1, c2, c3 from t1000000c04;
select c0, c1, c2, c3, c4 from t1000000c05;
select c0, c1, c2, c3, c4, c5 from t1000000c06;
select c0, c1, c2, c3, c4, c5, c6 from t1000000c07;
select c0, c1, c2, c3, c4, c5, c6, c7 from t1000000c08;
select c0, c1, c2, c3, c4, c5, c6, c7, c8 from t1000000c09;


-- fetches
select 0 from t1000000c01;
select 0 from t1000000c02;
select 0 from t1000000c03;
select 0 from t1000000c04;
select 0 from t1000000c05;
select 0 from t1000000c06;
select 0 from t1000000c07;
select 0 from t1000000c08;
select 0 from t1000000c09;
select 0 from t1000000c10;


select 0 from t1000000c10 where                 c4                               = 500000;
select 0 from t1000000c10 where                     c5                           = 500000;
select 0 from t1000000c10 where                 c4 + c5                          = 500000 * 2;
select 0 from t1000000c10 where             c3 + c4 + c5                         = 500000 * 3;
select 0 from t1000000c10 where                 c4 + c5 + c6                     = 500000 * 3;
select 0 from t1000000c10 where             c3 + c4 + c5 + c6                    = 500000 * 4;
select 0 from t1000000c10 where         c2 + c3 + c4 + c5 + c6                   = 500000 * 5;
select 0 from t1000000c10 where             c3 + c4 + c5 + c6 + c7               = 500000 * 5;
select 0 from t1000000c10 where         c2 + c3 + c4 + c5 + c6 + c7              = 500000 * 6;
select 0 from t1000000c10 where     c1 + c2 + c3 + c4 + c5 + c6 + c7             = 500000 * 7;
select 0 from t1000000c10 where         c2 + c3 + c4 + c5 + c6 + c7 + c8         = 500000 * 7;
select 0 from t1000000c10 where     c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8        = 500000 * 8;
select 0 from t1000000c10 where c0 + c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8       = 500000 * 9;
select 0 from t1000000c10 where     c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9   = 500000 * 9;
select 0 from t1000000c10 where c0 + c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9  = 500000 * 10;
