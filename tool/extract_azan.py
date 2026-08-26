#!/usr/bin/env python3
"""Extract the 2026 azan (call to prayer) times from the mosque spreadsheet.

The workbook stores most times as Excel fractional days (0.271... = 06:31) but
a few cells are plain "HH:MM" strings, so both forms are handled. The date
column in the sheet is unreliable, with the label shifted by a day in places,
so dates are rebuilt from each month block and then checked against the
weekday the sheet itself records.

Writes a JSON file of 365 days, each with the six times.
"""

import argparse
import datetime
import json
import re
import xml.etree.ElementTree as ET
import zipfile

NS = "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}"
MONTHS = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
]
# Column letters of the azan block.
COLS = {"Fajr": "D", "Shrooq": "E", "Zuhr": "F", "Asr": "G",
        "Maghreb": "H", "Isha": "I"}


def read_grid(path):
    """Return {(row, column_letter): value} for the first worksheet."""
    z = zipfile.ZipFile(path)

    shared = []
    if "xl/sharedStrings.xml" in z.namelist():
        root = ET.fromstring(z.read("xl/sharedStrings.xml"))
        for si in root.findall(f"{NS}si"):
            shared.append("".join(t.text or "" for t in si.iter(f"{NS}t")))

    grid = {}
    root = ET.fromstring(z.read("xl/worksheets/sheet1.xml"))
    for row in root.iter(f"{NS}row"):
        rn = int(row.get("r"))
        for c in row.findall(f"{NS}c"):
            col = re.match(r"([A-Z]+)", c.get("r")).group(1)
            v = c.find(f"{NS}v")
            if v is None or v.text is None:
                continue
            grid[(rn, col)] = (
                shared[int(v.text)] if c.get("t") == "s" else v.text
            )
    return grid


def to_minutes(raw):
    """Convert a cell to minutes past midnight, or None if it isn't a time."""
    if raw is None:
        return None
    raw = str(raw).strip()
    if not raw:
        return None
    if ":" in raw:                                  # already "HH:MM"
        h, m = raw.split(":")[:2]
        return int(h) * 60 + int(m)
    try:
        f = float(raw)
    except ValueError:
        return None
    if not 0 <= f < 1:                              # day numbers, not times
        return None
    return round(f * 24 * 60)


def hhmm(mins):
    return f"{mins // 60:02d}:{mins % 60:02d}"


def extract(path, year=2026):
    grid = read_grid(path)

    # Each month block starts with a row whose column C reads "Date".
    headers = sorted(rn for (rn, c), v in grid.items()
                     if c == "C" and v == "Date")

    days = {}
    for h in headers:
        month_name = None
        for back in range(1, 5):
            v = grid.get((h - back, "C"))
            if v and v.startswith("Call Times for"):
                month_name = v.replace("Call Times for", "").strip()
                break
        if month_name not in MONTHS:
            continue
        month = MONTHS.index(month_name) + 1

        # Data rows run until the times stop parsing.
        day_of_month = 0
        rn = h + 1
        while True:
            fajr = to_minutes(grid.get((rn, "D")))
            if fajr is None:
                break
            day_of_month += 1
            try:
                date = datetime.date(year, month, day_of_month)
            except ValueError:
                break

            # The sheet records the weekday in column B; use it as a check.
            weekday = (grid.get((rn, "B")) or "").strip()
            if weekday and weekday != date.strftime("%A"):
                raise SystemExit(
                    f"row {rn}: sheet says {weekday} but {date} is a "
                    f"{date.strftime('%A')}"
                )

            times = {}
            for name, col in COLS.items():
                m = to_minutes(grid.get((rn, col)))
                if m is None:
                    raise SystemExit(f"row {rn}: missing {name}")
                times[name] = hhmm(m)
            days[date.isoformat()] = times
            rn += 1

    return days


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("workbook")
    ap.add_argument("-o", "--out", required=True)
    ap.add_argument("--year", type=int, default=2026)
    args = ap.parse_args()

    days = extract(args.workbook, args.year)

    expected = 366 if args.year % 4 == 0 and (
        args.year % 100 != 0 or args.year % 400 == 0) else 365
    print(f"days extracted: {len(days)} (expected {expected})")

    missing = []
    d = datetime.date(args.year, 1, 1)
    while d.year == args.year:
        if d.isoformat() not in days:
            missing.append(d.isoformat())
        d += datetime.timedelta(days=1)
    if missing:
        print(f"MISSING {len(missing)}: {missing[:10]}")
    else:
        print("every day of the year is present")

    with open(args.out, "w") as f:
        json.dump({"year": args.year, "days": days}, f,
                  separators=(",", ":"), sort_keys=True)
    print("wrote", args.out)


if __name__ == "__main__":
    main()
