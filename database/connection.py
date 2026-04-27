import os
from pathlib import Path
import importlib
import sqlite3

load_dotenv = importlib.import_module("dotenv").load_dotenv

ROOT = Path(__file__).resolve().parent.parent
load_dotenv(ROOT / ".env")
load_dotenv(ROOT / "app" / ".env")


def get_database_url() -> str | None:
    return (
        os.getenv("DATABASE_URL")
        or os.getenv("database_url")
        or os.getenv("POSTGRES_URL")
        or os.getenv("NEON_DATABASE_URL")
    )


def get_connection():
    database_url = get_database_url()
    if database_url:
        psycopg = importlib.import_module("psycopg")
        return psycopg.connect(database_url)

    sqlite_db = ROOT / "database" / "akilli_finans.db"
    if not sqlite_db.exists():
        raise RuntimeError(
            "DATABASE_URL bulunamadi ve SQLite veritabani da yok. .env veya app/.env icine DATABASE_URL ekleyin."
        )
    return sqlite3.connect(sqlite_db)
