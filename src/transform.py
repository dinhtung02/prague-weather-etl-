def transform(city, hourly):
    rows = []
    for t, temp, rain, wind in zip(hourly["time"], hourly["temperature_2m"],
                                   hourly["precipitation"], hourly["wind_speed_10m"]):
        rows.append((city, t + "+00:00", temp, rain, wind))
    return rows