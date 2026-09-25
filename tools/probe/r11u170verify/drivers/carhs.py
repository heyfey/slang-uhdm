#!/usr/bin/env python3
"""carhs.py <db>...: per elaborated continuous assignment (uhdmtopModules section), the line and the Rhs object's
kind with its decompile/size/value/const type (measurement only)."""
import os, subprocess, sys, re
for f in sys.argv[1:]:
    t = subprocess.run([os.environ['UHDM_DUMP'], f], capture_output=True, text=True, errors='replace').stdout.splitlines()
    try: s = t.index('|uhdmtopModules:')
    except ValueError: s = 0
    out = []; i = s
    while i < len(t):
        l = t[i]
        m = re.match(r'^(\s*)\\_cont_assign: , line:(\S+), endln:(\S+)', l)
        if m and i + 3 < len(t) and '|vpiParent:' in t[i+1]:
            ind = len(m.group(1)); j = i + 1; rhs = []
            while j < len(t) and not t[j].strip().startswith('|vpiRhs:'): j += 1
            if j < len(t):
                k = j + 1; rhs.append(t[k].strip()); k += 1
                while k < len(t) and t[k].strip().startswith('|vpi') or (k < len(t) and re.match(r'\s*\|(U?INT|BIN|HEX|DEC|STRING):', t[k])):
                    if re.search(r'vpiDecompile|vpiSize|INT:|BIN:|HEX:|DEC:|vpiConstType|vpiOpType', t[k]): rhs.append(t[k].strip())
                    if t[k].strip() in ('|vpiLhs:',): break
                    k += 1
            out.append(f'  ca {m.group(2)}-{m.group(3)}: ' + ' '.join(rhs))
        i += 1
    print(f'== {f}'); print('\n'.join(out))
