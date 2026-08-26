# r10uvm154 — pull the enum_const cells out of an uhdm-dump.
# Used by score154.py; the corpus census uses ct154cen.cpp instead (uhdm-dump is
# unusable at Earlgrey/UVM size).
# extract enum_const cells from a uhdm-dump: (name, occurrence#) -> (value, decompile, size)
import re, sys, os
def cells(path):
    if not os.path.exists(path): return None
    out = []
    lines = open(path, errors="replace").read().split("\n")
    i = 0
    while i < len(lines):
        m = re.search(r"\\_enum_const: \(([^)]*)\)", lines[i])
        if m:
            nm = m.group(1); val=dec=sz=""
            for j in range(i+1, min(i+12, len(lines))):
                s = lines[j].strip()
                if s.startswith("\\_enum_const:") or s.startswith("\\_enum_typespec:") and j>i+2: pass
                if re.match(r"\|(INT|UINT|BIN|HEX|OCT|DEC|STRING|REAL):", s): val = s[1:]
                elif s.startswith("|vpiDecompile:"): dec = s[len("|vpiDecompile:"):]
                elif s.startswith("|vpiSize:"): sz = s[len("|vpiSize:"):]
                elif re.match(r"\\_enum_const: ", s): break
            out.append((nm, val, dec, sz))
        i += 1
    return out
