#!/usr/bin/env python3
"""pmovers.py <law probe workdir> <pristine probe workdir> <out.tsv>: every probe database whose bytes
differ between the two sweeps, judged against its cached golden (scripts/check_probe.py's cache key)
with uhdm-strictcmp --max 100000 on both: the records that LEAVE (pristine only) and ENTER (law only),
keyed by walk index + field + record text.  Probe cases hold no corpus source (no fenced test)."""
import os, subprocess, sys, filecmp
from concurrent.futures import ThreadPoolExecutor
R = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..'))
sys.path.insert(0, os.path.join(R, 'scripts'))
import check_probe as cp
SC = os.environ.get('SC', '/tmp/r11u169_bin/strictcmp')
L, P, OUT = sys.argv[1:4]
def recs(txt):
    out = set(); ls = txt.split('\n'); i = 0
    while i < len(ls):
        if ls[i].startswith('#') and i + 2 < len(ls):
            out.add((ls[i], ls[i + 2].strip())); i += 3
        else:
            i += 1
    return out
def one(fn):
    rel = fn[:-5].replace('__', '/')
    g = os.path.join(cp.cache_dir(rel), 'golden.uhdm')
    r = []
    for d in (P, L):
        p = subprocess.run([SC, '--max', '100000', g, os.path.join(d, fn)], capture_output=True, text=True)
        r.append(p.stdout + p.stderr)
    a, b = recs(r[0]), recs(r[1])
    va = r[0].strip().split('\n')[-1]; vb = r[1].strip().split('\n')[-1]
    first_l = sorted(a - b)[:1]; first_e = sorted(b - a)[:1]
    return f"{rel}\t{len(a-b)}\t{len(b-a)}\t{va}\t{vb}\t{first_l}\t{first_e}"
movers = [f for f in sorted(os.listdir(P)) if f.endswith('.uhdm') and
          not filecmp.cmp(os.path.join(P, f), os.path.join(L, f), shallow=False)]
with ThreadPoolExecutor(3) as ex:
    rows = list(ex.map(one, movers))
with open(OUT, 'w') as o:
    o.write("case\tleave\tenter\tpristine\tlaw\tfirst_leave\tfirst_enter\n")
    for x in rows: o.write(x + '\n')
print(f"probe movers: {len(movers)}; with entering records: {sum(1 for x in rows if x.split(chr(9))[2] != '0')}")
