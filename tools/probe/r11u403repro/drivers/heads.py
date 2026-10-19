#!/usr/bin/env python3
# heads.py <matrix.csv> <workroot> <out.csv>: uhdm-cmp head (golden first object line + first RHS object line) per DIFFERENT/JUDGE_EQUAL row
import csv, os, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
mx, wr, out = sys.argv[1:4]
CMP = os.environ['UHDM_CMP']
rows = [r for r in csv.DictReader(open(mx)) if r['agreement'] == 'DIFFERENT']
def gold(w):
    for l in open(os.path.join(w, 'cmds.txt')):
        m = re.search(r'cache hit (\S+)\)', l)
        if m: return os.path.join(m.group(1), 'golden.uhdm')
    p = os.path.join(w, 'slpp_all', 'surelog.uhdm')
    return p if os.path.exists(p) else None
def one(r):
    w = os.path.join(wr, r['path'][:-3]); g = gold(w); o = os.path.join(w, 'slang.uhdm')
    if not g or not os.path.exists(o): return (r['path'], 'nodb', '', '')
    try:
        t = subprocess.run([CMP, g, o], capture_output=True, text=True, timeout=600).stderr + ''
    except subprocess.TimeoutExpired:
        return (r['path'], 'timeout', '', '')
    L = t.splitlines()
    def first(tag):
        if tag not in L: return ''
        i = L.index(tag)
        for x in L[i+1:]:
            if x.startswith('decompile:'): continue
            return re.sub(r'id:\d+, ', '', x)[:150]
        return ''
    return (r['path'], 'ok', first('LHS:'), first('RHS:'))
with ThreadPoolExecutor(3) as ex:
    res = list(ex.map(one, rows))
with open(out, 'w', newline='') as f:
    w = csv.writer(f); w.writerow(['path', 'st', 'lhs', 'rhs'])
    for x in res: w.writerow(x)
print(len(res))
