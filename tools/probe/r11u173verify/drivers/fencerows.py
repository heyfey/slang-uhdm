#!/usr/bin/env python3
"""fencerows.py <wdA> <wdB>...: compares the csv rows of the fenced tests between sweeps WITHOUT printing their names
(rows are counted and compared as whole lines; fail-closed on $FENCED).  Only the gate csvs are read, never a source
or a database."""
import os, re, sys, csv
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('fencerows.py: source drivers/env.sh first')
def rows(wd, st):
    out = {}
    for r in csv.DictReader(open(f'{wd}/{st}.csv')):
        n = r.get('name', '')
        if any(re.search(rf'\b{re.escape(f)}\b', n) for f in F): out[(F.index(next(f for f in F if re.search(rf'\b{re.escape(f)}\b', n))), r['mode'])] = (r['status'], r.get('strict', ''))
    return out
wds = sys.argv[1:]
for st in ('surelog', 'uhdm2rtlil'):
    base = rows(wds[0], st)
    for wd in wds[1:]:
        o = rows(wd, st); same = sum(1 for k in base if o.get(k) == base[k])
        print(f'{st}: fenced row-modes {len(base)} in {os.path.basename(wds[0])}; identical (status, strict) in {os.path.basename(wd)}: {same}/{len(base)}')
