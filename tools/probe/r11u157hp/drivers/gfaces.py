#!/usr/bin/env python3
"""r11u157: the facets of grid cases (analyze.py's alignment + the committed mode-4 rule).
Args: <out root> [--all] [case ...]. Prints per case: verdict, then every facet (hier_path family only unless --all)."""
import sys, os, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from analyze import analyze, load
from common import rekey
root = sys.argv[1]; allf = '--all' in sys.argv; names = [a for a in sys.argv[2:] if a != '--all']
dirs = sorted(d for d in glob.glob(f'{root}/**/verdict', recursive=True))
for v in dirs:
    d = os.path.dirname(v); rel = os.path.relpath(d, root)
    if names and not any(rel == n or rel.startswith(n + '/') for n in names): continue
    ver = open(v).read().split()
    st = open(f'{d}/strict.out').read().split('\n') if os.path.exists(f'{d}/strict.out') else []
    head = [l for l in st if l.startswith(('STRICT_', 'fields:'))]
    print(f'== {rel} {" ".join(ver)} {" | ".join(head)}')
    if not os.path.exists(f'{d}/g.a'): continue
    try:
        r = analyze('g', 'x', rel, f'{d}/g.a', f'{d}/o.b', f'/tmp/r11u157_ga_{os.getpid()}', f'{d}/strict.out')
    except Exception as e:
        print('   ERR', e); continue
    for x in r['rows']:
        k = rekey(x)
        if allf or 'hier_path' in k or 'hier_path' in x.get('chain', ''):
            print(f"   {k:60s} #{x['ia']}/{x['ib']} {x['name']:12s} G[{x['golden']}] O[{x['ours']}]  < {x['chain']}")
