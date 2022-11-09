COPY aka_name FROM '$DATA_PATH/aka_name.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY aka_title FROM '$DATA_PATH/aka_title.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY cast_info FROM '$DATA_PATH/cast_info.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY char_name FROM '$DATA_PATH/char_name.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY comp_cast_type FROM '$DATA_PATH/comp_cast_type.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY company_name FROM '$DATA_PATH/company_name.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY company_type FROM '$DATA_PATH/company_type.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY complete_cast FROM '$DATA_PATH/complete_cast.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY info_type FROM '$DATA_PATH/info_type.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY keyword FROM '$DATA_PATH/keyword.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY kind_type FROM '$DATA_PATH/kind_type.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY link_type FROM '$DATA_PATH/link_type.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY movie_companies FROM '$DATA_PATH/movie_companies.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY movie_info FROM '$DATA_PATH/movie_info.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY movie_info_idx FROM '$DATA_PATH/movie_info_idx.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY movie_keyword FROM '$DATA_PATH/movie_keyword.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY movie_link FROM '$DATA_PATH/movie_link.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY name FROM '$DATA_PATH/name.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY person_info FROM '$DATA_PATH/person_info.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY role_type FROM '$DATA_PATH/role_type.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');
COPY title FROM '$DATA_PATH/title.csv' with (delimiter ',', FORMAT csv, NULL 'NULL');