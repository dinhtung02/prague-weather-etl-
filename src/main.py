import argparse

from extract import extract
from transform import transform
from load import load

CITIES = {
    "Prague":  (50.08, 14.42),
    "Brno":    (49.20, 16.61),
    "Ostrava": (49.82, 18.26),
    "Plzen":   (49.75, 13.38),
    "Olomouc": (49.59, 17.25),
}


def main():
    parser = argparse.ArgumentParser(description="Load Czech weather data into PostgreSQL")
    parser.add_argument("--start", required=True, help="Start date, YYYY-MM-DD")
    parser.add_argument("--end", required=True, help="End date, YYYY-MM-DD")
    args = parser.parse_args()

    for city, (lat, lon) in CITIES.items():
        try:
            hourly = extract(lat, lon, args.start, args.end)
            rows = transform(city, hourly)
            load(rows)
            print(f"{city}: loaded {len(rows)} rows")
        except Exception as error:
            print(f"{city}: FAILED - {error}")


if __name__ == "__main__":
    main()