#!/usr/bin/env python3
"""patab14.py <dump> <section> — one line per param_assign of a listing section
(uhdmallModules / uhdmtopModules / uhdmallPackages / uhdmtopPackages): the row's
source line, the Rhs object kind, and — when it is a constant — its size,
decompile and vpiConstType.  The pass-14 package/import heads are all
"same decimal, different vpiConstType", which the raw dump buries under 40
lines of typespec noise per row."""
import re
import sys

txt = open(sys.argv[1]).read().split("\n")
want = sys.argv[2]
start = None
for i, l in enumerate(txt):
    if l.startswith("|" + want + ":"):
        start = i
        break
    if l.startswith("|uhdm") and start is not None:
        break
if start is None:
    sys.exit(f"section {want} not found")
end = len(txt)
for i in range(start + 1, len(txt)):
    if txt[i].startswith("|uhdm"):
        end = i
        break
sec = txt[start:end]

owner = "?"
i = 0
while i < len(sec):
    l = sec[i]
    m = re.match(r"^(\s*)\\_(module_inst|package): (\S+)", l)
    if m and len(m.group(1)) <= 2:
        owner = m.group(3)
    m = re.match(r"^(\s*)\\_param_assign: , line:(\d+):(\d+)", l)
    if m:
        ind = len(m.group(1))
        row = m.group(2)
        rhs = None
        j = i + 1
        while j < len(sec):
            s = sec[j]
            if not s.startswith(" " * ind) or re.match(
                r"^\s{0,%d}\\_" % (ind - 1), s
            ):
                break
            if s.strip() == "|vpiRhs:":
                k = j + 1
                mk = re.match(r"^\s*\\_(\w+): ,? ?(?:\(([^)]*)\) ,? ?)?line:(\d+):(\d+)", sec[k])
                kind = mk.group(1) if mk else sec[k].strip()
                info = ""
                if kind == "constant":
                    kind_ind = len(sec[k]) - len(sec[k].lstrip())
                    sz = dc = ct = None
                    for q in range(k + 1, min(k + 30, len(sec))):
                        t = sec[q].strip()
                        qi = len(sec[q]) - len(sec[q].lstrip())
                        if qi <= kind_ind:
                            break
                        if qi != kind_ind + 2:
                            continue
                        if t.startswith("|vpiSize:"):
                            sz = t.split(":", 1)[1]
                        elif t.startswith("|vpiDecompile:"):
                            dc = t.split(":", 1)[1]
                        elif t.startswith("|vpiConstType:"):
                            ct = t.split(":", 1)[1]
                    info = f" sz={sz} dec={dc} ct={ct}"
                rhs = kind + info
                break
            j += 1
        print(f"{owner:<24} {row:>4}  Rhs={rhs}")
    i += 1
