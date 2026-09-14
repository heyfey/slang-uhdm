#!/usr/bin/env python3
"""r11u23 SHAPE LISTER — one line per ELABORATED cont_assign.

Keyed by (Lhs kind, Lhs name, Lhs line:col).  Prints
   ACT=<vpiActual kind|no>       FACE A
   RHS=<kind> <size/value/decompile/constType/opType of the TOP object>
                                 FACE B
Reads the dump's own nesting, so a param_assign's Rhs is never mistaken for a
cont_assign's.  usage: carhs23.py <dump> [...]
"""
import sys, re


def ind(l):
    return len(l) - len(l.lstrip(' '))


def blockfields(L, k):
    """describe the object whose header is at line k"""
    m = re.match(r'^ *\\_([a-z_]+):\s*(?:\(([^)]*)\))?(.*)$', L[k].rstrip())
    if not m:
        return '?', '', ''
    kind = m.group(1)
    name = (m.group(2) or '').split('.')[-1]
    b = ind(L[k])
    bits = []
    z = k + 1
    while z < len(L) and (not L[z].strip() or ind(L[z]) > b):
        s = L[z].strip()
        if s.startswith('\\_') or s.startswith('|vpi') and s.endswith(':'):
            pass
        mm = re.match(r'^\|(vpiSize|vpiDecompile|vpiConstType|vpiOpType|INT|UINT|'
                      r'BIN|HEX|OCT|STRING|REAL|vpiName):(.*)$', s)
        if mm and ind(L[z]) == b + 2:
            bits.append(mm.group(1) + ':' + mm.group(2))
        z += 1
    return kind, name, ' '.join(bits)


def rows(path):
    L = open(path, errors='replace').read().split('\n')
    out = []
    sect = 'pre'
    for i, l in enumerate(L):
        if 'uhdmallModules' in l:
            sect = 'def'
        elif 'uhdmtopModules' in l:
            sect = 'elab'
        elif 'weaklyReferenced' in l:
            sect = 'weak'
        if sect != 'elab':
            continue
        if not re.match(r'^ *\\_cont_assign: ', l):
            continue
        b = ind(l)
        lhs = rhs = None
        z = i + 1
        while z < len(L) and (not L[z].strip() or ind(L[z]) > b):
            s = L[z].strip()
            if ind(L[z]) == b + 2 and s == '|vpiLhs:' and lhs is None:
                k, n, f = blockfields(L, z + 1)
                act = 'no'
                lb = ind(L[z + 1])
                y = z + 2
                while y < len(L) and (not L[y].strip() or ind(L[y]) > lb):
                    if L[y].strip() == '|vpiActual:' and ind(L[y]) == lb + 2:
                        act = blockfields(L, y + 1)[0]
                        break
                    y += 1
                loc = re.search(r'line:(\d+:\d+)', L[z + 1])
                lhs = (k, n, loc.group(1) if loc else '-', act)
            elif ind(L[z]) == b + 2 and s == '|vpiRhs:' and rhs is None:
                k, n, f = blockfields(L, z + 1)
                rhs = (k, n, f)
            z += 1
        if lhs:
            out.append((lhs, rhs))
    return out


for p in sys.argv[1:]:
    if len(sys.argv) > 2:
        print('#', p)
    for lhs, rhs in rows(p):
        k, n, loc, act = lhs
        rk, rn, rf = rhs if rhs else ('-', '', '')
        print('  %-12s %-10s @%-8s ACT=%-12s RHS=%-10s %s %s'
              % (k, n, loc, act, rk, rn, rf))
