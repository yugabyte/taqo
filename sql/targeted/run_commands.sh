# Yugabyte
python3.10 src/runner.py collect --optimizations --ddls=none --model=targeted --config=config/targeted_bnl.conf --output=targeted_without_alias_bnl --database=taqo --verbose --enable-statistics

# Postgres
python3.10 src/runner.py collect --optimizations --model=targeted --config=config/targeted.conf --output=targeted_without_alias_pg --database=taqo --verbose --db=postgres --port=5432

# Report Compare PG vs YB Excel
python3.10 src/runner.py report --type=score_xls --config=config/targeted.conf --results=report/targeted_without_alias_bnl.json --pg-results=report/targeted_without_alias_pg.json

# Report Compare PG vs YB 
python3.10 src/runner.py report --type=score --config=config/targeted.conf --results=report/targeted_without_alias_bnl.json --pg-results=report/targeted_without_alias_pg.json


