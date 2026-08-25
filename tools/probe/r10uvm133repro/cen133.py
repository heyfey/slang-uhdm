#!/usr/bin/env python3
"""r10uvm133 — RHS-of-assignment census over a uhdm-dump.

MEASUREMENT ONLY.  For every `assignment` in the dump it reports the KIND of
the object hanging off `|vpiRhs:` and, when that object is a constant, its
`UINT:`/`vpiDecompile` digits.  Keyed on the assignment's SOURCE LINE (the arm
files put exactly one probe cell per line), never on a slot index and never on
an object id.  Usage: cen133.py <dump> [<tag>]
"""
import re, sys

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): *(\([^)]*\))?(?:, line:(\d+):(\d+), endln:(\d+):(\d+))?')

def cells(path):
    lines = open(path, encoding='utf-8', errors='replace').read().split('\n')
    out = []
    i = 0
    while i < len(lines):
        m = OBJ.match(lines[i])
        if m and m.group(2) == 'assignment' and m.group(4):
            aline = int(m.group(4))
            ind = len(m.group(1))
            # walk this assignment's own field list (indent ind+2) for vpiRhs
            j = i + 1
            rhs = None
            while j < len(lines):
                mm = OBJ.match(lines[j])
                if mm and len(mm.group(1)) <= ind and j > i:
                    break
                if lines[j].strip() == '|vpiRhs:' and len(lines[j]) - len(lines[j].lstrip()) == ind + 2:
                    k = j + 1
                    mk = OBJ.match(lines[k])
                    if mk:
                        kind = mk.group(2)
                        val = ''
                        nm = (mk.group(3) or '').strip('()')
                        if kind == 'constant':
                            kind_ind = len(mk.group(1))
                            t = k + 1
                            dec = uint = ''
                            while t < len(lines):
                                s = lines[t]
                                if OBJ.match(s) and len(OBJ.match(s).group(1)) <= kind_ind:
                                    break
                                st = s.strip()
                                if st.startswith('|vpiDecompile:'):
                                    dec = st.split(':', 1)[1]
                                if re.match(r'^\|(U?INT|STRING):', st):
                                    uint = st[1:]
                                t += 1
                            val = f'{uint}/dec={dec}'
                        rhs = (kind, nm, val)
                    break
                j += 1
            if rhs:
                out.append((aline, rhs[0], rhs[1], rhs[2]))
        i += 1
    return out

if __name__ == '__main__':
    tag = sys.argv[2] if len(sys.argv) > 2 else ''
    for c in cells(sys.argv[1]):
        print(f'{tag}\tL{c[0]}\t{c[1]}\t{c[2]}\t{c[3]}')
