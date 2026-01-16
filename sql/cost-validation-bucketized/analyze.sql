create statistics t100_c1c4 on c1, c4 from t100;
create statistics t100_c2c2expr on c2, (c2*2 - c2) from t100;
create statistics t100_c3c4 on c3, c4 from t100;
create statistics t100_c4c4expr on c2, (c4*2 - c4) from t100;

create statistics t1000_c1c4 on c1, c4 from t1000;
create statistics t1000_c2c2expr on c2, (c2*2 - c2) from t1000;
create statistics t1000_c3c4 on c3, c4 from t1000;
create statistics t1000_c4c4expr on c2, (c4*2 - c4) from t1000;

create statistics t100000_c1c4 on c1, c4 from t100000;
create statistics t100000_c2c2expr on c2, (c2*2 - c2) from t100000;
create statistics t100000_c3c4 on c3, c4 from t100000;
create statistics t100000_c4c4expr on c2, (c4*2 - c4) from t100000;

create statistics t100000w_c1c4 on c1, c4 from t100000w;
create statistics t100000w_c2c2expr on c2, (c2*2 - c2) from t100000w;
create statistics t100000w_c3c4 on c3, c4 from t100000w;
create statistics t100000w_c4c4expr on c2, (c4*2 - c4) from t100000w;

create statistics t1000000m_c1c2 on c1, c2 from t1000000m;
create statistics t1000000m_c1c2c3 on c1, c2, c3 from t1000000m;
create statistics t1000000m_c2c3c4 on c2, c3, c4 from t1000000m;
create statistics t1000000m_c2c4 on c2, c4 from t1000000m;
create statistics t1000000m_c3c4 on c3, c4 from t1000000m;
create statistics t1000000m_c3c4c5 on c3, c4, c5 from t1000000m;
create statistics t1000000m_c4c5 on c4, c5 from t1000000m;


create statistics t100_c1mod on (c1 % 2) from t100;
create statistics t1000_c1mod on (c1 % 2) from t1000;
create statistics t10000_c1mod on (c1 % 2) from t10000;
create statistics t100000_c1mod on (c1 % 2) from t100000;
create statistics t100000w_c1mod on (c1 % 2) from t100000w;
create statistics t1000000m_c1mod on (c1 % 2) from t1000000m;

create statistics t100_c2mod on (c2 % 2) from t100;
create statistics t1000_c2mod on (c2 % 2) from t1000;
create statistics t10000_c2mod on (c2 % 2) from t10000;
create statistics t100000_c2mod on (c2 % 2) from t100000;
create statistics t100000w_c2mod on (c2 % 2) from t100000w;
create statistics t1000000m_c2mod on (c2 % 2) from t1000000m;

create statistics t100_c3mod on (c3 % 2) from t100;
create statistics t1000_c3mod on (c3 % 2) from t1000;
create statistics t10000_c3mod on (c3 % 2) from t10000;
create statistics t100000_c3mod on (c3 % 2) from t100000;
create statistics t100000w_c3mod on (c3 % 2) from t100000w;
create statistics t1000000m_c3mod on (c3 % 2) from t1000000m;

create statistics t100_c4mod on (c4 % 2) from t100;
create statistics t1000_c4mod on (c4 % 2) from t1000;
create statistics t10000_c4mod on (c4 % 2) from t10000;
create statistics t100000_c4mod on (c4 % 2) from t100000;
create statistics t100000w_c4mod on (c4 % 2) from t100000w;
create statistics t1000000m_c4mod on (c4 % 2) from t1000000m;

create statistics table_simple_c1c4 on c1, c4 from table_simple;
create statistics table_simple_c2c2expr on c2, (c2*2 - c2) from table_simple;
create statistics table_simple_c3c4 on c3, c4 from table_simple;
create statistics table_simple_c4c4expr on c2, (c4*2 - c4) from table_simple;

create statistics table_bucketized_c1c4 on c1, c4 from table_bucketized;
create statistics table_bucketized_c2c2expr on c2, (c2*2 - c2) from table_bucketized;
create statistics table_bucketized_c3c4 on c3, c4 from table_bucketized;
create statistics table_bucketized_c4c4expr on c2, (c4*2 - c4) from table_bucketized;


analyze t100;
analyze t1000;
analyze t10000;
analyze t100000;
analyze t100000w;
analyze t1000000m;
analyze table_simple;
analyze table_bucketized;
