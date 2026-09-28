#!/usr/bin/env python3
"""r11u191: every cont_assign Rhs of a uhdm-dump text as `<cont_assign line> <rhs kind> <rhs line/name>`,
the definition listing first, then the elaborated one (the second occurrence of a cont_assign line).
usage: rhskinds.py <dump>"""
import sys, re, collections
L = open(sys.argv[1]).read().split('\n')
seen = collections.Counter()
for i, l in enumerate(L):
    m = re.match(r'^(\s*)\\_cont_assign: , line:(\d+):', l)
    if not m: continue
    ind = len(m.group(1))
    for k in range(i + 1, min(i + 400, len(L))):
        if len(L[k]) - len(L[k].lstrip()) <= ind and L[k].strip(): break
        if L[k].strip() == '|vpiRhs:':
            r = L[k + 1].strip()
            ln = m.group(2); seen[ln] += 1
            print(f"ca@{ln} #{seen[ln]} {r[:60]}")
            break
