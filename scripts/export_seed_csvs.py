"""
Export seed data from the ABC Store database to CSV files.
"""

from abc_store.seed_export import export_all_seed_csvs


def main() -> None:
    export_all_seed_csvs(
        seed_dir="seed_data",
        dotenv_path=".env",
        include_schemas=None,
        exclude_tables=None,
        verbose=True,
    )


if __name__ == "__main__":
    main()