#!/usr/bin/env python3
"""pactab14.py <dump> — project a uhdm-dump onto the (line -> constant) table of
every param_assign Rhs constant: value string, size, const type and whether a
vpiTypespec ref is present.  The pass-14 package heads are all "same decimal,
different vpiConstType / missing ref_typespec", which no raw dump diff shows
without 40 lines of noise around it."""
import re
import sys

lines = open(sys.argv[1]).read().split("\n")
rows = {}
for i, l in enumerate(lines):
    m = re.match(r"^(\s*)\\_constant: , (?:\(([^)]*)\) , )?line:(\d+):(\d+)", l)
    if not m:
        m2 = re.match(r"^(\s*)constant: , line:(\d+):(\d+)", l)
        if not m2:
            continue
        ind, ln, col = m2.group(1), m2.group(2), m2.group(3)
    else:
        ind, ln, col = m.group(1), m.group(3), m.group(4)
    val = ct = sz = None
    hasts = False
    depth = len(ind)
    for j in range(i + 1, min(i + 26, len(lines))):
        s = lines[j]
        if not s.startswith(" " * depth):
            break
        t = s.strip()
        if t.startswith("|vpiConstType:"):
            ct = t.split(":")[1]
        elif t.startswith("|vpiSize:"):
            sz = t.split(":")[1]
        elif t.startswith("|vpiTypespec:"):
            hasts = True
        elif re.match(r"^\|(INT|UINT|BIN|HEX|OCT|DEC|STRING|REAL|SCALAR):", t):
            val = t[1:]
        elif t.startswith("\\_constant:") or t.startswith("\\_param_assign:"):
            break
    key = (int(ln), int(col))
    rows.setdefault(key, set()).add((val, sz, ct, hasts))
for k in sorted(rows):
    for v in sorted(rows[k], key=str):
        print(f"{k[0]:>4}:{k[1]:<3} val={v[0]} sz={v[1]} ct={v[2]} ts={'Y' if v[3] else '-'}")
