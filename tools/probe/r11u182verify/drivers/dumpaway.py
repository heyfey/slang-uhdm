#!/usr/bin/env python3
"""dumpaway.py <GW dir> [on_tag]: the order-blind uhdm-dump judge on EVERY case (aligned or stage 1): uhdm-dump lines
(paths stripped to basenames) as multisets, per state T against ON: lost = golden-agreeing lines T had that ON lost
(a field the law moved away, including fields neither comparator reads: vpiParent, vpiFullName computed through the
parent chain, the unreachable tail), gained = golden-agreeing lines ON has that T lacked.  Fail-closed on $FENCED."""
import os, sys, glob, subprocess, collections, re, pickle
if len(os.environ.get('FENCED', '').split()) != 4: sys.exit('dumpaway.py: source drivers/env.sh first')
DUMP = os.environ['UHDM_DUMP']; FEN = os.environ['FENCED'].split()
def lines(u):
    m = u + '.dms'
    if os.path.exists(m) and os.path.getmtime(m) >= os.path.getmtime(u): return pickle.load(open(m, 'rb'))
    t = subprocess.run([DUMP, u], capture_output=True, text=True, errors='replace').stdout
    c = collections.Counter(re.sub(r'/[^ ,:()]*/', '', l).rstrip() for l in t.splitlines() if 'Restored design' not in l)
    pickle.dump(c, open(m, 'wb')); return c
gw = sys.argv[1]; on = sys.argv[2] if len(sys.argv) > 2 else 'on'
for w in sorted(glob.glob(f'{gw}/**/{on}.uhdm', recursive=True)):
    d = os.path.dirname(w); rel = os.path.relpath(d, gw)
    if any(re.search(rf'\b{re.escape(n)}\b', d) for n in FEN): continue
    g = glob.glob(f'{d}/gold_*/golden.uhdm')
    if not g: continue
    G = lines(g[0]); O = lines(w)
    for t in sorted(glob.glob(f'{d}/*.uhdm')):
        tag = os.path.basename(t)[:-5]
        if tag == on: continue
        T = lines(t)
        if T == O: continue
        lost = (T & G) - O; gained = (O & G) - T
        det = (' | ' + ' || '.join(k.strip()[:120] for k in list(lost)[:3])) if lost else ''
        print(rel, tag, f'lost={sum(lost.values())}', f'gained={sum(gained.values())}', det)
