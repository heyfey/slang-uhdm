#!/usr/bin/env python3
"""paspan14.py <dump> — EVERY param_assign in the dump, in file order, with its
owner listing entry, the row line, and the Rhs object's kind + FULL SPAN (+ the
constant's size / decompile / const-type / whether it carries a vpiTypespec).
patab14.py answers "constant or operation"; the pass-14 ternary law is about
WHERE the folded constant is anchored, which needs the span."""
import re
import sys

txt = open(sys.argv[1]).read().split("\n")
owner = "?"
sect = "?"
for i, l in enumerate(txt):
    if l.startswith("|uhdm"):
        sect = l.strip("|:")
        continue
    m = re.match(r"^(\s*)\\_(module_inst|package): (\S+)", l)
    if m and len(m.group(1)) == 0:
        owner = m.group(3)
        continue
    m = re.match(r"^(\s*)\\_param_assign: , line:(\d+):(\d+)", l)
    if not m:
        continue
    ind = len(m.group(1))
    row = m.group(2)
    j = i + 1
    while j < len(txt):
        s = txt[j]
        si = len(s) - len(s.lstrip())
        if si <= ind and s.strip():
            break
        if s.strip() == "|vpiRhs:":
            k = j + 1
            mk = re.match(
                r"^(\s*)\\_(\w+): ,? ?(?:\(([^)]*)\) ,? ?)?(?:file:[^,]*, )?"
                r"line:(\d+):(\d+), endln:(\d+):(\d+)",
                txt[k],
            )
            if not mk:
                print(f"{sect:<16} {owner:<12} {row:>4}  Rhs={txt[k].strip()[:60]}")
                break
            kind = mk.group(2)
            span = f"{mk.group(4)}:{mk.group(5)}-{mk.group(6)}:{mk.group(7)}"
            ki = len(mk.group(1))
            extra = ""
            if kind == "constant":
                sz = dc = ct = None
                ts = "-"
                for q in range(k + 1, min(k + 40, len(txt))):
                    t = txt[q].strip()
                    qi = len(txt[q]) - len(txt[q].lstrip())
                    if qi <= ki:
                        break
                    if qi != ki + 2:
                        continue
                    if t.startswith("|vpiSize:"):
                        sz = t.split(":", 1)[1]
                    elif t.startswith("|vpiDecompile:"):
                        dc = t.split(":", 1)[1]
                    elif t.startswith("|vpiConstType:"):
                        ct = t.split(":", 1)[1]
                    elif t.startswith("|vpiTypespec:"):
                        ts = "Y"
                extra = f" sz={sz} dec={dc} ct={ct} ts={ts}"
            print(f"{sect:<16} {owner:<12} {row:>4}  {kind} @{span}{extra}")
            break
        j += 1
