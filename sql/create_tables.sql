-- Creates the main table for prague-weather-etl.
-- Run while connected to the "weather" database.
-- Grain: one row per city per hour (timestamps in UTC).

CREATE TABLE IF NOT EXISTS weather_hourly (
    city          TEXT         NOT NULL,
    observed_at   TIMESTAMPTZ  NOT NULL,
    temperature_c NUMERIC(4,1),
    precip_mm     NUMERIC(5,1),
    wind_kmh      NUMERIC(5,1),
    loaded_at     TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (city, observed_at)
);