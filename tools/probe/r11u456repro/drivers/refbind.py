#!/usr/bin/env python3
"""refbind.py <a.uhdm> <b.uhdm>: multiset of (ref_obj name, line:col, actual kind+fullname)
from uhdm-dump, printed as a diff (golden-only '<', ours-only '>')."""
import os, re, subprocess, sys, collections
dump = os.environ.get('UHDM_DUMP')
def refs(p):
    out = subprocess.run([dump, p], capture_output=True, text=True).stdout.splitlines()
    res = collections.Counter()
    for i, l in enumerate(out):
        m = re.match(r'^(\s*)(?:\\_)?ref_obj: \(([^)]*)\).*?line:(\d+:\d+)', l.replace('|', ' '))
        if not m:
            continue
        ind = len(m.group(1))
        act = '-'
        for j in range(i + 1, min(i + 40, len(out))):
            lj = out[j].replace('|', ' ')
            indj = len(lj) - len(lj.lstrip())
            if indj <= ind and ('ref_obj' in lj or not lj.strip().startswith('vpi') and '\\_' not in lj):
                pass
            if lj.strip().startswith('vpiActual:'):
                a = out[j + 1].replace('|', ' ').strip().lstrip('\\_')
                act = re.sub(r', id:\d+', '', a)
                break
            if indj < ind + 1 and j > i + 1 and re.match(r'\s*\\_', lj) is None and 'vpi' not in lj:
                break
            if re.match(r'^\s*(\\_)?\w+: ', lj) and indj <= ind:
                break
        res[(m.group(2), m.group(3), act)] += 1
    return res
a, b = refs(sys.argv[1]), refs(sys.argv[2])
for k in sorted((a - b).elements()):
    print('<', *k)
for k in sorted((b - a).elements()):
    print('>', *k)
