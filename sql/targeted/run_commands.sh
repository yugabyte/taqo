# Yugabyte
python3.10 src/runner.py collect --optimizations --ddls=none --model=targetted --config=config/targetted_bnl.conf --output=targetted_without_alias_bnl --database=taqo --verbose --enable-statistics

# Postgres
python3.10 src/runner.py collect --optimizations --model=targetted --config=config/targetted.conf --output=targetted_without_alias_pg --database=taqo --verbose --db=postgres --port=5432

# Report Compare PG vs YB Excel
python3.10 src/runner.py report --type=score_xls --config=config/targetted.conf --results=report/targetted_without_alias_bnl.json --pg-results=report/targetted_without_alias_pg.json

# Report Compare PG vs YB 
python3.10 src/runner.py report --type=score --config=config/targetted.conf --results=report/targetted_without_alias_bnl.json --pg-results=report/targetted_without_alias_pg.json


