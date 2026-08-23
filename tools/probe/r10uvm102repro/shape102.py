#!/usr/bin/env python3
"""Extract and score the r10uvm102 parameter / param_assign shape."""

from collections import Counter, defaultdict
import re
import sys

TARGET_LINES = {2, 3, 4, 5, 13, 17, 28, 33, 34, 35, 36, 44}
REL = re.compile(r"^( *)(\|vpi[A-Za-z0-9_]+:)$")
OBJ = re.compile(r"^( *)\\_([A-Za-z0-9_]+):")
LOC = re.compile(r"line:(\d+):(\d+),")
FULL = re.compile(r"\(([^()]*)\)")


def blocks(lines, relationship):
    marker = f"|{relationship}:"
    i = 0
    while i < len(lines):
        m = REL.match(lines[i])
        if not m or m.group(2) != marker:
            i += 1
            continue
        indent = len(m.group(1))
        j = i + 1
        while j < len(lines):
            n = REL.match(lines[j])
            if n and len(n.group(1)) == indent:
                break
            j += 1
        yield indent, lines[i:j]
        i = j


def direct(block, indent, prefix):
    pad = " " * (indent + 2)
    return any(line.startswith(pad + prefix) for line in block)


def extract(path):
    lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
    rows = []
    for indent, block in blocks(lines, "vpiParameter"):
        if len(block) < 2:
            continue
        loc = LOC.search(block[1])
        full = FULL.search(block[1])
        if not loc or not full or int(loc.group(1)) not in TARGET_LINES:
            continue
        ts = int(direct(block, indent, "|vpiTypespec:"))
        rows.append(("P", full.group(1), loc.group(1), loc.group(2), str(ts)))

    for indent, block in blocks(lines, "vpiParamAssign"):
        if len(block) < 2:
            continue
        loc = LOC.search(block[1])
        if not loc or int(loc.group(1)) not in TARGET_LINES:
            continue
        pad = " " * (indent + 2)
        scope = ""
        lhs = ""
        rhs = []
        in_rhs = False
        in_lhs = False
        for line in block[2:]:
            if line == pad + "|vpiRhs:":
                in_rhs, in_lhs = True, False
                continue
            if line == pad + "|vpiLhs:":
                in_rhs, in_lhs = False, True
                continue
            if not scope and line.startswith(pad + "\\_"):
                sm = re.search(r"\\_(?:package|module_inst|class_defn):.*?\(([^()]*)\)", line)
                if sm:
                    scope = sm.group(1)
            if in_lhs and line.startswith(pad + "\\_parameter:"):
                fm = FULL.search(line)
                if fm:
                    lhs = fm.group(1)
            if in_rhs:
                rhs.append(line)
        size = ""
        value = ""
        ts = "0"
        actual = "0"
        for line in rhs:
            text = line.strip()
            if text.startswith("|vpiSize:"):
                size = text.split(":", 1)[1]
            elif re.match(r"\|(BIN|OCT|DEC|HEX|INT|UINT):", text):
                value = text[1:]
            elif text == "|vpiTypespec:":
                ts = "1"
            elif text == "|vpiActual:":
                actual = "1"
        rows.append(("A", scope, lhs, loc.group(1), loc.group(2), value,
                     size, ts, actual))
    return sorted(rows)


def key_value(row):
    if row[0] == "P":
        return row[:4], row[4:]
    return row[:5], row[5:]


def grouped(rows):
    out = defaultdict(list)
    for row in rows:
        key, value = key_value(row)
        out[key].append(value)
    for values in out.values():
        values.sort()
    return out


def score(gold, pristine, patched):
    gs, ps, qs = map(grouped, (gold, pristine, patched))
    counts = Counter()
    for key in sorted(set(gs) | set(ps) | set(qs)):
        gl, pl, ql = gs.get(key, []), ps.get(key, []), qs.get(key, [])
        n = max(len(gl), len(pl), len(ql))
        for i in range(n):
            g = gl[i] if i < len(gl) else None
            p = pl[i] if i < len(pl) else None
            q = ql[i] if i < len(ql) else None
            if p == g and q == g:
                counts["STILL_RIGHT"] += 1
            elif p != g and q == g:
                counts["TO_GOLDEN"] += 1
            elif p == g and q != g:
                counts["AWAY_GOLDEN"] += 1
            elif p != q:
                counts["MOVED_WRONG"] += 1
            else:
                counts["STILL_WRONG"] += 1
    for name in ("STILL_RIGHT", "TO_GOLDEN", "AWAY_GOLDEN",
                 "MOVED_WRONG", "STILL_WRONG"):
        print(f"{name}={counts[name]}")


if len(sys.argv) == 2:
    for row in extract(sys.argv[1]):
        print("\t".join(row))
elif len(sys.argv) == 4:
    score(*(extract(path) for path in sys.argv[1:]))
else:
    raise SystemExit("usage: shape102.py DUMP | GOLD PRISTINE PATCHED")
