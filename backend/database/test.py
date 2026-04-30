from backend.database.connection import get_connection


with get_connection() as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT 1;")
        print(cur.fetchone())