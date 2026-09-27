#!/usr/bin/env python3
"""unmaskposrow.py <off_wd> <on_wd> <corpus/mode/name>...: unmaskpos.py for CORPUS rows (the golden read from the
row's cmds.txt): the walk index where off's strict walk diverged and the index of every record on has that off had
not.  Fenced rows refused (fail-closed on $FENCED)."""
import os, re, sys, glob, subprocess, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('unmaskposrow.py: source drivers/env.sh first')
SC = os.environ['STRICT_CMP']; OFF, ON = sys.argv[1:3]
def paths(w, key):
    c, m, n = key.split('/')
    if any(re.search(rf'\b{re.escape(f)}\b', n) for f in F): sys.exit('fenced refused')
    d = glob.glob(f'{w}/{c}/{m}/{n}-*')[0]
    g = re.search(r'golden cache [a-z]* ([^)]*)\)', open(d + '/cmds.txt').read()).group(1)
    return glob.glob(g + '/*.uhdm')[0], d + '/slang.uhdm'
def recs(g, o):
    r = subprocess.run([SC, '--max', '100000', g, o], capture_output=True, text=True, errors='replace').stdout
    L = r.splitlines(); out = []
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m and i + 2 < len(L): out.append((int(m.group(1)), m.group(2), L[i+1].strip(), L[i+2].strip()))
    return out, any('diverged' in l for l in L)
for key in sys.argv[3:]:
    g, a0 = paths(OFF, key); _, b0 = paths(ON, key)
    a, da = recs(g, a0); b, db = recs(g, b0)
    sa = collections.Counter((f, x, y) for _, f, x, y in a)
    new = [i for i, f, x, y in b if sa[(f, x, y)] == 0]
    offdiv = a[-1][0] if (a and da) else None; ondiv = b[-1][0] if (b and db) else None
    ok = offdiv is not None and all(i >= offdiv for i in new)
    print(f'{key}: off {len(a)} rec, diverged at #{offdiv}; on {len(b)} rec, diverged at #{ondiv}; new at {new[:20]} -> {"UNMASK (all at/after off divergence)" if ok else "NEW BEFORE DIVERGENCE"}', flush=True)
