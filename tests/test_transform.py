from transform import transform


def test_builds_one_row_per_hour_with_utc_marker():
    hourly = {
        "time": ["2026-01-01T00:00", "2026-01-01T01:00"],
        "temperature_2m": [-1.5, -2.0],
        "precipitation": [0.0, 0.2],
        "wind_speed_10m": [10.0, 12.5],
    }

    rows = transform("Prague", hourly)

    assert len(rows) == 2
    assert rows[0] == ("Prague", "2026-01-01T00:00+00:00", -1.5, 0.0, 10.0)


def test_keeps_missing_values_as_none():
    hourly = {
        "time": ["2026-01-01T00:00"],
        "temperature_2m": [None],
        "precipitation": [0.0],
        "wind_speed_10m": [None],
    }

    rows = transform("Brno", hourly)

    assert rows[0][2] is None   # temperature
    assert rows[0][4] is None   # wind


def test_empty_input_gives_no_rows():
    hourly = {"time": [], "temperature_2m": [], "precipitation": [], "wind_speed_10m": []}

    assert transform("Ostrava", hourly) == []