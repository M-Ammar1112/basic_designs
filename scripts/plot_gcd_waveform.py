#!/usr/bin/env python3
"""Render a simple GCD simulation snapshot PNG from gcd_waveform.vcd."""

from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    import matplotlib.pyplot as plt
except ImportError:
    print("matplotlib is required: pip install matplotlib", file=sys.stderr)
    sys.exit(1)


def parse_vcd(path: Path):
    id_to_name: dict[str, str] = {}
    widths: dict[str, int] = {}
    timeline: dict[str, list[tuple[int, int]]] = {}
    time = 0

    var_re = re.compile(r"\$var\s+\w+\s+(\d+)\s+(\S+)\s+(\S+)")
    time_re = re.compile(r"^#(\d+)")
    scalar_re = re.compile(r"^([01xXzZ])(\S+)$")
    vector_re = re.compile(r"^[bB]([01xXzZ]+)\s+(\S+)$")

    with path.open() as fh:
        for raw in fh:
            line = raw.strip()
            if not line:
                continue

            m = var_re.match(line)
            if m:
                width = int(m.group(1))
                vid = m.group(2)
                name = m.group(3)
                id_to_name[vid] = name
                widths[vid] = width
                timeline[vid] = [(0, 0)]
                continue

            m = time_re.match(line)
            if m:
                time = int(m.group(1))
                continue

            m = scalar_re.match(line)
            if m:
                vid = m.group(2)
                if vid in timeline:
                    val = 0 if m.group(1) in "0xXzZ" else 1
                    timeline[vid].append((time, val))
                continue

            m = vector_re.match(line)
            if m:
                bits, vid = m.group(1), m.group(2)
                if vid in timeline:
                    clean = "".join("0" if c in "xXzZ" else c for c in bits)
                    timeline[vid].append((time, int(clean, 2) if clean else 0))

    return id_to_name, timeline


def series(samples: list[tuple[int, int]], t_end: int):
    xs, ys = [], []
    for i, (t, v) in enumerate(samples):
        xs.append(t)
        ys.append(v)
        t_next = samples[i + 1][0] if i + 1 < len(samples) else t_end
        xs.append(t_next)
        ys.append(v)
    return xs, ys


def main():
    root = Path(__file__).resolve().parents[1]
    vcd = root / "gcd_waveform.vcd"
    out = root / "design" / "GCD" / "reports" / "gcd_simulation_snapshot.png"
    out.parent.mkdir(parents=True, exist_ok=True)

    if not vcd.exists():
        print(f"Missing {vcd}; run: make gcd-run", file=sys.stderr)
        sys.exit(1)

    id_to_name, timeline = parse_vcd(vcd)
    name_to_id = {name: vid for vid, name in id_to_name.items()}

    wanted = [
        ("clk", "clk"),
        ("reset", "reset"),
        ("start", "start"),
        ("x_i", "x_i"),
        ("y_i", "y_i"),
        ("x_reg", "x_reg"),
        ("y_reg", "y_reg"),
        ("state", "state"),
        ("gcd", "gcd"),
        ("done", "done"),
    ]

    t_end = 0
    for samples in timeline.values():
        if samples:
            t_end = max(t_end, samples[-1][0])
    t_end = max(t_end, 350000)

    fig, axes = plt.subplots(len(wanted), 1, figsize=(12, 8), sharex=True)
    fig.suptitle("GCD simulation — (56,48)=8, (24,24)=24, (39,52)=13", fontsize=12)

    for ax, (label, name) in zip(axes, wanted):
        vid = None
        for key, value in name_to_id.items():
            if key == name or key.endswith("." + name) or key.split(".")[-1] == name:
                vid = value
                break
        if vid is None:
            # fuzzy match on suffix
            for key, value in name_to_id.items():
                if key.endswith(name):
                    vid = value
                    break

        ax.set_ylabel(label, rotation=0, ha="right", va="center", labelpad=28, fontsize=8)
        ax.set_yticks([])
        ax.grid(True, axis="x", linestyle=":", alpha=0.4)

        if vid is None or vid not in timeline:
            ax.text(0.01, 0.5, "(not in VCD)", transform=ax.transAxes, fontsize=8)
            continue

        xs, ys = series(timeline[vid], t_end)
        # convert time unit (1ps dumps, timescale 1ns/1ps => values already in 1ps)
        xs_ns = [x / 1000.0 for x in xs]
        ax.step(xs_ns, ys, where="post", linewidth=1.1)
        if max(ys) > 1:
            ax.set_ylim(-0.5, max(ys) * 1.15)
            ax.set_yticks([0, max(ys)])
            ax.set_yticklabels(["0", str(max(ys))], fontsize=7)
        else:
            ax.set_ylim(-0.1, 1.2)

    axes[-1].set_xlabel("time (ns)")
    fig.tight_layout(rect=[0.02, 0.02, 1, 0.96])
    fig.savefig(out, dpi=140)
    print(f"Wrote {out}")


if __name__ == "__main__":
    main()
