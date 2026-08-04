#!/usr/bin/env python3
"""cst.py <dump> [lineLo lineHi] — project every `constant` in a uhdm-dump onto
   "<view> L<line>:<col> dec=<decompile> sz=<size> ct=<constType>", indentation-
   aware (a nested |vpiParent: block no longer truncates the scan)."""
import re, sys

f = sys.argv[1]
lo = int(sys.argv[2]) if len(sys.argv) > 2 else 0
hi = int(sys.argv[3]) if len(sys.argv) > 3 else 10 ** 9
lines = open(f).read().split("\n")
view = ""
for i, l in enumerate(lines):
    if l.startswith("|uhdm"):
        view = l.strip("|:")
    m = re.match(r"(\s*)\\_constant: , line:(\d+):(\d+)", l)
    if not m:
        continue
    ln = int(m.group(2))
    if not (lo <= ln <= hi):
        continue
    ind = len(m.group(1))
    dec = size = ct = None
    for j in range(i + 1, len(lines)):
        s = lines[j]
        if not s.strip():
            break
        cur = len(s) - len(s.lstrip())
        if cur <= ind:
            break
        t = s.strip()
        # only the constant's OWN scalars (depth ind+2), never a nested object's
        if cur != ind + 2:
            continue
        if t.startswith("|vpiDecompile:") and dec is None:
            dec = t[14:]
        elif t.startswith("|vpiSize:") and size is None:
            size = t[9:]
        elif t.startswith("|vpiConstType:") and ct is None:
            ct = t[14:]
    if dec is not None and len(dec) > 20:
        dec = dec[:12] + "..%d" % len(dec)
    print(f"{view:18s} L{m.group(2)}:{m.group(3):>3s} dec={dec} sz={size} ct={ct}")
