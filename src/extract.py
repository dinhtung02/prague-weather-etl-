import requests

URL = "https://archive-api.open-meteo.com/v1/archive"

def extract(lat, lon, start, end):
    param = {
        'latitude': lat, 'longitude': lon,
        'start_date': start, 'end_date': end,
        'hourly': 'temperature_2m,precipitation,wind_speed_10m',
        'timezone':'GMT'
    }
    response = requests.get(URL, params = param, timeout = 30)
    response.raise_for_status()
    return response.json()['hourly']