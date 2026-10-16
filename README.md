# Czech Weather ETL Pipeline

An end-to-end ETL pipeline that extracts a year of hourly weather data for five Czech cities from the Open-Meteo API, transforms it in Python, loads it idempotently into PostgreSQL, and answers ten business questions in SQL.

## Architecture

```mermaid
flowchart LR
    A[Open-Meteo API] -->|extract.py| B[Python]
    B -->|transform.py| C[Rows in UTC]
    C -->|load.py: upsert| D[(PostgreSQL)]
    D -->|analysis.sql| E[10 business questions]
```

## Tech stack

Python 3 · requests · psycopg · PostgreSQL · SQL (window functions, CTEs) · pytest · Git

## Data

- **Source:** [Open-Meteo Historical Weather API](https://open-meteo.com/en/docs/historical-weather-api) 
- **Cities:** Prague, Brno, Ostrava, Plzeň, Olomouc
- **Period:** 1 Oct 2025 – 30 Sep 2026, hourly
- **Volume:** 43,800 rows (5 cities × 8,760 hours)
- **Grain:** one row per city per hour

## Key findings

1. [e.g. Ostrava is the city with the most rainy day during the period Oct 2025 to Sep 2026 ]
2. [e.g. Brno and Olomouc are tie with the most dry day consecutive period of 14 days]
3. [e.g. Prague is the windiest during the evening rush hour]

## Design decisions

- **Idempotent loads:** a primary key on `(city, observed_at)` with `INSERT … ON CONFLICT DO UPDATE` means the pipeline can be re-run safely without duplicates.
- **Timestamps in UTC:** stored as `TIMESTAMPTZ` to avoid the duplicate hour during the autumn daylight-saving change; converted to Prague time in queries.
- **Separated ETL steps:** extract, transform and load live in separate modules, so each can be tested and changed independently.
- **Fault tolerance per city:** one city failing doesn't stop the others.
- **Secrets out of code:** database settings are read from a `.env` file that is never committed.

## How to run

1. Clone the repo and create a virtual environment:
```
   git clone https://github.com/[your-username]/prague-weather-etl.git
   cd prague-weather-etl
   python -m venv .venv
   .venv\Scripts\activate          # Mac/Linux: source .venv/bin/activate
   pip install -r requirements.txt
```
2. Create a PostgreSQL database and table:
   run `sql/setup.sql`, then `sql/create_tables.sql` on the `weather` database.
3. Copy `.env.example` to `.env` and set your PostgreSQL password.
4. Load the data:
```
   python src/main.py --start 2025-10-01 --end 2026-09-30
```
5. Explore the results with the queries in `sql/analysis.sql`.

## Tests

```
python -m pytest
```

## Project structure

```
├── sql/
│   ├── setup.sql            # creates the database
│   ├── create_tables.sql    # table definition
│   └── analysis.sql         # 10 business questions
├── src/
│   ├── extract.py           # calls the API
│   ├── transform.py         # reshapes data into rows
│   ├── load.py              # upserts into PostgreSQL
│   └── main.py              # runs the pipeline for all cities
├── tests/
│   └── test_transform.py
├── .env.example
└── requirements.txt
```

## What I'd improve next

- Schedule daily incremental loads with Apache Airflow
- Add retries with exponential backoff for API calls
- Run everything with Docker Compose
- Add data-quality checks (row counts, null rates) after each load