.DEFAULT_GOAL := help
# Force “safe behavior”:
# `make` → runs help -> Enforces displaying instructions in case only `make` is run without arguments.

.PHONY: help populate_db export_seed_csvs validate

help:
	@echo "Targets:"
	@echo "  make populate  - Populate DB with dummy data"
	@echo "  make export    - Export CSV seed files"

populate_db:
	python -m scripts.populate_db

export_seed_csvs:
	python -m scripts.export_seed_csvs