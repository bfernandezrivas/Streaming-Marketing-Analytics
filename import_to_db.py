"""
import_to_db.py
----------------
Targeted competencies:
    C3 — Final aggregation/cleaning pass before storage: deduplication,
         format standardization across the merged API + IMDb data-file
         sources.
    C4 — Functional import into a relational database created from
         the physical model (schema.sql).

Requirements:
    pip install pandas mysql-connector-python

Prerequisites:
    - schema.sql already executed on the target MySQL server
    - DATA/PROCESSED/all_streaming_titles_enriched.csv already produced
      by 02B_IMDB_DATASET_ENRICHMENT.ipynb

Expected environment variables (never commit real values):
    DB_HOST, DB_USER, DB_PASSWORD, DB_NAME
"""

import os
import sys
import logging
import pandas as pd
import mysql.connector
from mysql.connector import Error as MySQLError

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
log = logging.getLogger(__name__)

ENRICHED_PATH = "DATA/PROCESSED/all_streaming_titles_enriched.csv"


# ------------------------------------------------------------------
# 1. Load and do a final cleaning pass (C3)
# ------------------------------------------------------------------
def load_and_clean() -> pd.DataFrame:
    log.info(f"Loading enriched dataset: {ENRICHED_PATH}")
    df = pd.read_csv(ENRICHED_PATH, low_memory=False)

    before = len(df)
    df = df.drop_duplicates(subset=["title", "release_year", "content_type"], keep="first")
    df = df.dropna(subset=["title", "content_type"])
    df["content_type"] = df["content_type"].str.lower().str.strip()

    # Prefer the resolved imdb_id from the data-file matching step,
    # fall back to the original one if it was already valid.
    if "imdb_resolved_id" in df.columns:
        df["imdb_id"] = df["imdb_resolved_id"].where(
            df["imdb_resolved_id"].notna() & (df["imdb_resolved_id"] != ""),
            df.get("imdb_id"),
        )

    log.info(f"Cleaning pass: {before} -> {len(df)} rows kept.")
    return df


# ------------------------------------------------------------------
# 2. Functional import into MySQL (C4)
# ------------------------------------------------------------------
def get_connection():
    return mysql.connector.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        user=os.environ.get("DB_USER", "root"),
        password=os.environ.get("DB_PASSWORD", ""),
        database=os.environ.get("DB_NAME", "streaming_marketing"),
    )


def get_or_create(cursor, table, id_col, name_col, value):
    cursor.execute(f"SELECT {id_col} FROM {table} WHERE {name_col} = %s", (value,))
    row = cursor.fetchone()
    if row:
        return row[0]
    cursor.execute(f"INSERT INTO {table} ({name_col}) VALUES (%s)", (value,))
    return cursor.lastrowid


def get_or_create_person(cursor, full_name: str) -> int:
    cursor.execute("SELECT id_person FROM PERSON WHERE full_name = %s", (full_name,))
    row = cursor.fetchone()
    if row:
        return row[0]
    cursor.execute("INSERT INTO PERSON (full_name) VALUES (%s)", (full_name,))
    return cursor.lastrowid


def insert_people(cursor, id_content: int, names_field: str, role: str):
    """names_field is a ' | '-joined string, as produced by the enrichment notebook."""
    if not names_field or pd.isna(names_field):
        return
    names = [n.strip() for n in str(names_field).split("|") if n.strip()]
    for order, name in enumerate(names, start=1):
        id_person = get_or_create_person(cursor, name)
        cursor.execute(
            """INSERT IGNORE INTO CONTENT_PERSON (id_content, id_person, role, ordering)
               VALUES (%s,%s,%s,%s)""",
            (id_content, id_person, role, order),
        )


def import_dataframe(df: pd.DataFrame):
    conn = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        log.info("MySQL connection established.")

        inserted, skipped = 0, 0
        for _, row in df.iterrows():
            try:
                id_language = None
                if pd.notna(row.get("original_language")):
                    id_language = get_or_create(
                        cursor, "LANGUAGE_TABLE", "id_language", "language_code", row["original_language"]
                    )

                cursor.execute(
                    """INSERT INTO CONTENT
                       (title, original_title, content_type, id_language, release_year,
                        popularity, vote_average, vote_count, overview, imdb_id,
                        imdb_match_status, adult, source_origin)
                       VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                    (
                        row["title"], row.get("original_title"), row["content_type"], id_language,
                        row.get("release_year"), row.get("popularity"), row.get("vote_average"),
                        row.get("vote_count"), row.get("overview"), row.get("imdb_id"),
                        row.get("imdb_match_status"), bool(row.get("adult", False)),
                        "TMDb/TVMaze API",
                    ),
                )
                id_content = cursor.lastrowid

                for genre in str(row.get("genres", "")).split("|"):
                    genre = genre.strip()
                    if not genre:
                        continue
                    id_genre = get_or_create(cursor, "GENRE", "id_genre", "genre_name", genre)
                    cursor.execute(
                        "INSERT IGNORE INTO CONTENT_GENRE (id_content, id_genre) VALUES (%s,%s)",
                        (id_content, id_genre),
                    )

                cursor.execute(
                    """INSERT INTO SCORE
                       (id_content, visibility_score, engagement_score, reception_score, business_value_score)
                       VALUES (%s,%s,%s,%s,%s)""",
                    (
                        id_content, row.get("visibility_score"), row.get("engagement_score"),
                        row.get("reception_score"), row.get("business_value_score"),
                    ),
                )

                # People credits coming from the IMDb data-file enrichment (second source)
                insert_people(cursor, id_content, row.get("imdb_cast"), "cast")
                insert_people(cursor, id_content, row.get("imdb_directors"), "director")
                insert_people(cursor, id_content, row.get("imdb_cinematographers"), "cinematographer")

                inserted += 1
            except MySQLError as e:
                skipped += 1
                log.warning(f"Row skipped ({row.get('title')}): {e}")

        conn.commit()
        log.info(f"Import complete: {inserted} rows inserted, {skipped} skipped.")

    except MySQLError as e:
        log.error(f"MySQL connection/import error: {e}")
        if conn:
            conn.rollback()
        sys.exit(1)
    finally:
        if conn and conn.is_connected():
            conn.close()
            log.info("MySQL connection closed.")


if __name__ == "__main__":
    dataset = load_and_clean()
    import_dataframe(dataset)
