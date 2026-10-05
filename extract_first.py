import csv 
import requests 

url = "https://archive-api.open-meteo.com/v1/archive"
params = {
    "latitude": 50.08,
    "longitude": 14.42,
    "start_date": "2026-09-01",
    "end_date": "2026-09-07",
    "hourly": "temperature_2m,precipitation",
    "timezone": "Europe/Prague",
}

response = requests.get(url, params = params, timeout = 30)
response.raise_for_status() 
hourly = response.json()["hourly"]

with open("prague_week.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["time", "temperature_c", "precip_mm"])
    for t, temp, rain in zip(hourly["time"], hourly["temperature_2m"], hourly["precipitation"]):
        writer.writerow([t, temp, rain])

print(f"Saved {len(hourly['time'])} rows")