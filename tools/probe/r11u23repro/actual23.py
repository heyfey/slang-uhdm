#!/usr/bin/env python3
"""r11u23 SHAPE LISTER — FACE A.

For every `cont_assign` in a uhdm-dump, print the OWNER kind, the Lhs object
kind + name + line:col, and whether the Lhs ref_obj carries a `vpiActual`
(and of what kind).  `writeCont_assign` sets `ref->Actual_group(var)` only
inside `if (var)` — so this is the direct read-out of `bindVariable`'s answer.

Also prints the Rhs OBJECT KIND / size / value / decompile / constType /
opType, so FACE B (the fold) is scored from the same listing.

usage: actual23.py <dump> [<dump2> ...]
"""
import sys, re


def indent(l):
    m = re.match(r'^([ |\\_]*)', l)
    s = m.group(1)
    return len(s) - len(s.lstrip(' '))


def parse(path):
    L = open(path, errors='replace').read().split('\n')
    # section: everything after the LAST "uhdmtopModules" is the elaborated
    # listing; the dump repeats keys, so walk the whole file and tag each
    # cont_assign with the nearest preceding section marker.
    rows = []
    sect = 'pre'
    for i, l in enumerate(L):
        if 'uhdmallModules' in l:
            sect = 'def'
        elif 'uhdmtopModules' in l:
            sect = 'elab'
        elif 'weaklyReferenced' in l:
            sect = 'weak'
        if re.search(r'\\_cont_assign: ', l):
            base = indent(l)
            lhs_kind = lhs_name = lhs_loc = '-'
            actual = 'no'
            rhs_kind = rhs_desc = '-'
            j = i + 1
            while j < len(L) and j < i + 400:
                lj = L[j]
                if lj.strip() and indent(lj) <= base and not lj.lstrip(' |\\_').startswith(''):
                    pass
                if re.search(r'\\_cont_assign: ', lj):
                    break
                st = lj.strip()
                if st.startswith('|vpiLhs:'):
                    k = j + 1
                    if k < len(L):
                        m = re.match(r'^[ |\\_]*\\_([a-z_]+): (?:\(([^)]*)\))?(.*)$',
                                     L[k].rstrip())
                        if m:
                            lhs_kind = m.group(1)
                            lhs_name = (m.group(2) or '').split('.')[-1]
                            loc = re.search(r'line:(\d+:\d+)', m.group(3) or '')
                            lhs_loc = loc.group(1) if loc else '-'
                        lb = indent(L[k])
                        z = k + 1
                        while z < len(L) and indent(L[z]) > lb:
                            if L[z].strip().startswith('|vpiActual:'):
                                mm = re.match(r'^[ |\\_]*\\_([a-z_]+): ',
                                              L[z + 1].rstrip()) if z + 1 < len(L) else None
                                actual = mm.group(1) if mm else 'yes'
                                break
                            z += 1
                elif st.startswith('|vpiRhs:'):
                    k = j + 1
                    if k < len(L):
                        m = re.match(r'^[ |\\_]*\\_([a-z_]+): ', L[k].rstrip())
                        if m:
                            rhs_kind = m.group(1)
                        rb = indent(L[k])
                        bits = []
                        z = k + 1
                        while z < len(L) and indent(L[z]) > rb:
                            s2 = L[z].strip()
                            for key in ('|vpiSize:', '|vpiDecompile:', '|vpiConstType:',
                                        '|vpiOpType:', '|INT:', '|UINT:', '|BIN:',
                                        '|HEX:', '|STRING:', '|REAL:'):
                                if s2.startswith(key):
                                    bits.append(s2[1:])
                            if len(bits) > 6:
                                break
                            z += 1
                        rhs_desc = ' '.join(bits)
                    break
                j += 1
            rows.append((sect, lhs_kind, lhs_name, lhs_loc, actual, rhs_kind, rhs_desc))
    return rows


for p in sys.argv[1:]:
    print('#', p)
    for r in parse(p):
        print('  sect=%-4s lhs=%-14s %-10s @%-8s ACTUAL=%-12s rhs=%-14s %s' % r)
