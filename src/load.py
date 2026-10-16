import os
import psycopg
from dotenv import load_dotenv

SQL = """
    INSERT INTO weather_hourly (city, observed_at, temperature_c, precip_mm, wind_kmh)
    VALUES (%s, %s, %s, %s, %s)
    ON CONFLICT (city, observed_at) DO UPDATE SET
        temperature_c = EXCLUDED.temperature_c,
        precip_mm     = EXCLUDED.precip_mm,
        wind_kmh      = EXCLUDED.wind_kmh,
        loaded_at     = now()
"""


def get_connection():
    load_dotenv()
    return psycopg.connect(
        host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"),
    )


def load(rows):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.executemany(SQL, rows)