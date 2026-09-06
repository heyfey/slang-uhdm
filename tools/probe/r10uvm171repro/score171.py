#!/usr/bin/env python3
"""r10uvm171 — THE SCORER for predsweep171.sh output.  MEASUREMENT ONLY.

Reads the per-row GOLDEN / OURS listings ct171list prints and, PER ROW, joins
them as MULTISETS keyed on

    (line:col, kind, BOUND|BARE)

with the home chain carried as evidence but NOT as a key: the two producers
name the same clone differently in places (the DEF/ELAB view rule of RESUME
§9), and a key that carried the name would manufacture one-sided phantoms on
both sides at once.  Counts, never a last-writer dict.

Four columns per row, and the two that matter are the last two:

    AGREE        cells whose (span, kind, boundness) count matches
    TO-GOLDEN    golden BOUND where we are BARE  — what the law must MOVE
    AWAY         we BOUND where golden is BARE   — must be 0, before and after
    OTHER        a span present on one side only (a naming/span residue that
                 belongs to some other pass; listed so it is never silently
                 folded into either column)

usage: score171.py <predsweep-out.txt> [--rows]
"""
import re
import sys
from collections import Counter

ROW = re.compile(r"^=== (.*)$")
LINE = re.compile(r"^\s+(\d+):(\d+)\s+(\S+)\s+(BOUND|BARE)\s+act=(\S+)\s*(.*)$")


def main():
    path = sys.argv[1]
    show = "--rows" in sys.argv[2:]
    rows = {}
    cur, side = None, None
    for ln in open(path):
        m = ROW.match(ln.rstrip("\n"))
        if m:
            cur = m.group(1)
            rows.setdefault(cur, (Counter(), Counter(), []))
            side = None
            continue
        s = ln.strip()
        if s.startswith("---- GOLDEN"):
            side = 0
            continue
        if s.startswith("---- OURS"):
            side = 1
            continue
        m = LINE.match(ln.rstrip("\n"))
        if not m or cur is None or side is None:
            continue
        key = (int(m.group(1)), int(m.group(2)), m.group(3), m.group(4))
        rows[cur][side][key] += 1
        rows[cur][2].append((side, key, m.group(6).strip()))

    tot = Counter()
    for name, (g, o, ev) in sorted(rows.items()):
        agree = to_g = away = other = 0
        detail = []
        spans = {(k[0], k[1], k[2]) for k in list(g) + list(o)}
        for sp in sorted(spans):
            gb = g[(sp[0], sp[1], sp[2], "BOUND")]
            gr = g[(sp[0], sp[1], sp[2], "BARE")]
            ob = o[(sp[0], sp[1], sp[2], "BOUND")]
            orr = o[(sp[0], sp[1], sp[2], "BARE")]
            if gb + gr == 0 or ob + orr == 0:
                other += max(gb + gr, ob + orr)
                detail.append(("OTHER", sp, gb, gr, ob, orr))
                continue
            agree += min(gb, ob) + min(gr, orr)
            if gb > ob:
                to_g += gb - ob
                detail.append(("TO-GOLDEN", sp, gb, gr, ob, orr))
            if ob > gb:
                away += ob - gb
                detail.append(("AWAY", sp, gb, gr, ob, orr))
        tot["AGREE"] += agree
        tot["TO-GOLDEN"] += to_g
        tot["AWAY"] += away
        tot["OTHER"] += other
        if to_g or away or (show and other):
            print("%-46s agree=%-5d TO-GOLDEN=%-4d AWAY=%-4d OTHER=%d"
                  % (name.split("/")[-2] if "/" in name else name,
                     agree, to_g, away, other))
            for d in detail:
                if d[0] == "OTHER" and not show:
                    continue
                print("      %-10s %4d:%-3d %-20s golden B=%d b=%d | ours B=%d b=%d"
                      % (d[0], d[1][0], d[1][1], d[1][2], d[2], d[3], d[4], d[5]))
    print("TOTAL rows=%d agree=%d TO-GOLDEN=%d AWAY=%d OTHER=%d"
          % (len(rows), tot["AGREE"], tot["TO-GOLDEN"], tot["AWAY"], tot["OTHER"]))


main()
