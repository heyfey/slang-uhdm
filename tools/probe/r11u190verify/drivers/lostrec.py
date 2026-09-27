#!/usr/bin/env python3
"""lostrec.py <off_wd> <on_wd> <corpus/mode/name>...: the strict records (uhdm-strictcmp --max 100000, golden vs ours)
a corpus row loses and gains between two sweeps (off -> on): the multiset of (field, golden line, ours line), with
the first lost / gained record printed.  Fenced rows refused (fail-closed on $FENCED)."""
import os, re, sys, glob, subprocess, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('lostrec.py: source drivers/env.sh first')
SC = os.environ['STRICT_CMP']; OFF, ON = sys.argv[1:3]
def paths(w, key):
    c, m, n = key.split('/')
    if any(re.search(rf'\b{re.escape(f)}\b', n) for f in F): sys.exit('fenced refused')
    d = glob.glob(f'{w}/{c}/{m}/{n}-*')[0]
    g = re.search(r'golden cache [a-z]* ([^)]*)\)', open(d + '/cmds.txt').read()).group(1)
    return glob.glob(g + '/*.uhdm')[0], d + '/slang.uhdm'
def recs(g, o):
    L = subprocess.run([SC, '--max', '100000', g, o], capture_output=True, text=True, errors='replace').stdout.splitlines()
    c = collections.Counter(); idx = {}
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m and i + 2 < len(L):
            k = (m.group(2), L[i+1].strip(), L[i+2].strip()); c[k] += 1; idx.setdefault(k, m.group(1))
    return c, idx
for key in sys.argv[3:]:
    g, a = paths(OFF, key); _, b = paths(ON, key)
    ra, ia = recs(g, a); rb, ib = recs(g, b)
    lost = ra - rb; gained = rb - ra
    print(f'{key}: lost {sum(lost.values())} gained {sum(gained.values())}')
    for k in list(lost)[:3]: print(f'   LOST #{ia[k]} {k[0]} | {k[1][:140]} | {k[2][:140]}')
    for k in list(gained)[:3]: print(f'   GAINED #{ib[k]} {k[0]} | {k[1][:140]} | {k[2][:140]}')
