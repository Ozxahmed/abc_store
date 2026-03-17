from pathlib import Path

from psycopg2 import sql

from abc_store.db_utils import get_connection


class ExportResult:
    def __init__(
        self,
        schema: str,
        table: str,
        csv_path: str,
        ok: bool,
        message: str = "",
    ) -> None:
        self.schema = schema
        self.table = table
        self.csv_path = csv_path
        self.ok = ok
        self.message = message


DEFAULT_EXCLUDE_SCHEMAS = {
    "pg_catalog",
    "information_schema",
    "pg_toast",
} # Note for self: Variable written in ALL_CAPS because it should not normally change during runtime.


def _get_user_tables(cursor, include_schemas: list[str] | None = None):
    """
    Returns list of (schema, table) for user tables.
    """
    if include_schemas:
        cursor.execute(
            """
            SELECT schemaname, tablename
            FROM pg_catalog.pg_tables
            WHERE schemaname = ANY(%s)
            ORDER BY schemaname, tablename;
            """,
            (include_schemas,),
        )
    else:
        cursor.execute(
            """
            SELECT schemaname, tablename
            FROM pg_catalog.pg_tables
            WHERE schemaname <> ALL(%s)
              AND schemaname NOT LIKE 'pg_toast%%'
              AND schemaname NOT LIKE 'pg_temp%%'
            ORDER BY schemaname, tablename;
            """,
            (list(DEFAULT_EXCLUDE_SCHEMAS),),
        )

    return [(r[0], r[1]) for r in cursor.fetchall()]


def export_all_seed_csvs(
    seed_dir: str = "seed_data",
    dotenv_path: str | None = ".env",
    include_schemas: list[str] | None = None,
    exclude_tables: set[tuple[str, str]] | None = None,
    verbose: bool = True,
) -> list[ExportResult]:
    """
    Export one CSV per table into seed_dir/<schema>/<table>.csv using COPY.

    By default:
    - exports all user tables
    - excludes PostgreSQL system/internal schemas
    - writes one CSV per table with header row
    """
    seed_path = Path(seed_dir)
    seed_path.mkdir(parents=True, exist_ok=True)

    conn = get_connection(dotenv_path=dotenv_path, verbose=False)
    if conn is None:
        raise RuntimeError("No DB connection; cannot export seed CSVs.")

    results = []
    exclude_tables = exclude_tables or set()

    try:
        with conn:
            with conn.cursor() as cur:
                tables = _get_user_tables(cur, include_schemas=include_schemas)

                for schema, table in tables:
                    if (schema, table) in exclude_tables:
                        continue

                    if schema in DEFAULT_EXCLUDE_SCHEMAS:
                        continue

                    out_dir = seed_path / schema
                    out_dir.mkdir(parents=True, exist_ok=True)

                    out_path = out_dir / f"{table}.csv"

                    copy_sql = sql.SQL(
                        "COPY {}.{} TO STDOUT WITH CSV HEADER"
                    ).format(
                        sql.Identifier(schema),
                        sql.Identifier(table),
                    )

                    try:
                        with out_path.open("w", encoding="utf-8", newline="") as f:
                            cur.copy_expert(copy_sql, f)

                        results.append(
                            ExportResult(
                                schema=schema,
                                table=table,
                                csv_path=str(out_path),
                                ok=True,
                            )
                        )

                        if verbose:
                            print(f"[OK] Exported {schema}.{table} -> {out_path}")

                    except Exception as e:
                        results.append(
                            ExportResult(
                                schema=schema,
                                table=table,
                                csv_path=str(out_path),
                                ok=False,
                                message=str(e),
                            )
                        )

                        if verbose:
                            print(f"[FAIL] {schema}.{table}: {e}")

    finally:
        conn.close()

    failures = [r for r in results if not r.ok]
    if failures:
        raise RuntimeError(
            f"Seed export failed for {len(failures)} table(s). See logs/results."
        )

    return results