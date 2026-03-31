# Repository Guidelines

## Project Structure & Module Organization
- `src/`: Python sources. Entrypoint `src/runner.py`; actions in `src/actions/**`; DB adapters in `src/db/**`; shared utilities in `src/utils.py`.
- `sql/`: Query models and DDLs. Each model folder contains `create.sql`, optional `<prefix>.create.sql`, `import.sql`, `analyze.sql`, `drop.sql`, and `queries/*.sql`.
- `config/`: HOCON configs (e.g., `config/default.conf`).
- `report/`: Generated JSON inputs and rendered reports.
- `bin/`: Ready-made scenarios (`taqo.sh`, `regression.sh`, `selectivity.sh`).
- `docker/`, `adoc/`, `scripts/`, `dist/`: Packaging, docs assets, helpers.

## Build, Test, and Development Commands
- Environment: `python3 -m venv venv && source venv/bin/activate`
- Install: `pip install -r requirements.txt`
- Help/args: `python3 src/runner.py -h`
- Collect (basic model):
  `python3 src/runner.py collect --model=basic --config=config/default.conf --output=report/basic_run --yes`
- Report (regression):
  `python3 src/runner.py report --type=regression --config=config/default.conf --v1-results=report/run_v1.json --v2-results=report/run_v2.json`

## Coding Style & Naming Conventions
- Python 3.10+. Follow PEP 8 (4‑space indent, 88–100 col width). Use snake_case for modules/functions, PascalCase for classes.
- Prefer type hints and docstrings on public functions. Keep modules focused; place actions under `src/actions/` and reports under `src/actions/reports/`.
- Keep configuration defaults in HOCON; expose overrides via `--options key=value` and runner flags.

## Testing Guidelines
- No formal unit test suite. Validate changes by:
  - Running a small model: `--model=basic --num-queries=5`.
  - Comparing outputs across runs with `--type=regression`.
  - For plan-only checks use `--plans-only` to speed up.
- Ensure generated JSON lands in `report/` and reports render without errors.

## Commit & Pull Request Guidelines
- Commits: concise, sentence‑case summaries; include context (e.g., “Add parallel execution model”) and reference issues/PRs (`#123`) when applicable.
- PRs: include purpose, notable flags/config used, and how you validated (commands run, sample report paths). Attach screenshots or link HTML/PDF outputs from `report/` when useful.

## Security & Configuration Tips
- Do not commit credentials; pass via flags (`--username/--password`) or environment. Avoid checking in private data/models; use `sql/proprietary/` locally and `.gitignore` as needed.
- Use `--ddl-prefix` (e.g., `postgres`) to select DB‑specific DDLs without altering shared SQL.
