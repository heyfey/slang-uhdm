#!/usr/bin/env python3
"""pas.py <db>...: every param_assign in the dump (all sections, in order): the Lhs name and the Rhs object's
first line (kind + span) with its value/size/decompile (measurement only)."""
import os, subprocess, sys, re
for f in sys.argv[1:]:
    t = subprocess.run([os.environ['UHDM_DUMP'], f], capture_output=True, text=True, errors='replace').stdout.splitlines()
    print(f'== {f}'); sec = ''
    for i, l in enumerate(t):
        if l.startswith('|uhdm'): sec = l.strip('|:')
        m = re.match(r'^(\s*)\\_param_assign: , line:(\S+), endln:(\S+)', l)
        if not m: continue
        ind = len(m.group(1)); rhs = lhs = ''; j = i + 1; vals = []
        while j < len(t) and (len(t[j]) - len(t[j].lstrip())) > ind:
            s = t[j].strip()
            if s == '|vpiRhs:' and j + 1 < len(t): rhs = t[j+1].strip()
            if s == '|vpiLhs:' and j + 1 < len(t): lhs = t[j+1].strip()
            if rhs and not lhs and re.match(r'\|(U?INT|BIN|HEX|STRING|vpiSize|vpiDecompile)', s): vals.append(s)
            j += 1
        print(f'  [{sec}] pa {m.group(2)}-{m.group(3)} lhs={lhs[:50]} rhs={rhs[:60]} {" ".join(vals[:4])}')
