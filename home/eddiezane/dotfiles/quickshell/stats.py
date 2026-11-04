"""Read Linux counters once per tick; no third-party dependencies or shell parsing."""

import json
import os
from pathlib import Path
import sys
import time


def read(path):
    return Path(path).read_text().strip()


def cpu_times():
    # guest/guest_nice are already included in user/nice.
    ticks = list(map(int, read("/proc/stat").splitlines()[0].split()[1:9]))
    return sum(ticks), ticks[3] + ticks[4]


def snapshot(previous):
    current = cpu_times()
    elapsed = current[0] - previous[0]
    cpu = round(100 * (1 - (current[1] - previous[1]) / elapsed)) if elapsed > 0 else 0
    mem = {line.split(":")[0]: int(line.split()[1]) for line in read("/proc/meminfo").splitlines()}
    gib = 1024**2
    used = mem["MemTotal"] - mem["MemAvailable"]
    fs = os.statvfs("/")
    disk_used = (fs.f_blocks - fs.f_bfree) * fs.f_frsize
    disk_avail = fs.f_bavail * fs.f_frsize
    disk_percent = round(100 * disk_used / max(1, disk_used + disk_avail))
    temperatures = []
    cpu_temp = None
    for hwmon in sorted(Path("/sys/class/hwmon").glob("hwmon*")):
        try:
            name = read(hwmon / "name")
            for sensor in sorted(hwmon.glob("temp*_input")):
                value = int(read(sensor)) / 1000
                label = sensor.with_name(sensor.name.replace("_input", "_label"))
                title = read(label) if label.exists() else sensor.stem.replace("_input", "")
                temperatures.append(f"{name} {title}: {value:.0f}°C")
                if name in ("k10temp", "coretemp") and cpu_temp is None:
                    cpu_temp = round(value)
            for sensor in sorted(hwmon.glob("fan*_input")):
                temperatures.append(f"{name} {sensor.stem}: {read(sensor)} RPM")
        except (OSError, ValueError):
            continue
    brightness = None
    for backlight in sorted(Path("/sys/class/backlight").glob("*")):
        try:
            brightness = round(100 * int(read(backlight / "brightness")) / int(read(backlight / "max_brightness")))
            break
        except (OSError, ValueError, ZeroDivisionError):
            continue
    model = next((line.split(":", 1)[1].strip() for line in read("/proc/cpuinfo").splitlines() if line.startswith("model name")), "CPU")
    return current, {
        "cpu": max(0, min(100, cpu)),
        "cpuTooltip": f"{model}\nLoad average: {' '.join(read('/proc/loadavg').split()[:3])}",
        "memory": round(100 * used / mem["MemTotal"]),
        "memoryTooltip": f"Used: {used / gib:.1f} / {mem['MemTotal'] / gib:.1f} GiB\nAvailable: {mem['MemAvailable'] / gib:.1f} GiB\nSwap: {(mem['SwapTotal'] - mem['SwapFree']) / gib:.1f} / {mem['SwapTotal'] / gib:.1f} GiB",
        "disk": disk_percent,
        "diskTooltip": f"Root filesystem\nUsed: {disk_used / 1024**3:.1f} GiB\nAvailable: {disk_avail / 1024**3:.1f} GiB",
        "temperature": cpu_temp,
        "temperatureTooltip": "\n".join(temperatures) or "No temperature sensor data",
        "brightness": brightness,
    }


if __name__ == "__main__":
    previous = cpu_times()
    while True:
        time.sleep(0.25 if "--once" in sys.argv else 2)
        previous, data = snapshot(previous)
        print(json.dumps(data), flush=True)
        if "--once" in sys.argv:
            break
