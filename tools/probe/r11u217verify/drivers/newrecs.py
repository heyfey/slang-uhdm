#!/usr/bin/env python3
# (r11u217) newrecs.py <off wd> <on wd> <corpus> <mode> <row>: the strict records of ON that OFF does not hold (field,
# golden, ours), each with its walk index and, when OFF holds a record with the same field and golden text but other
# ours text, that record (the same object written differently: MOVED); else NEW.  Also prints OFF's divergence index.
# Refuses a fenced row (fail-closed on $FENCED).
import os, re, sys, glob, subprocess, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('newrecs.py: source drivers/env.sh first')
OFF, ON, C, M, R = sys.argv[1:6]
if any(re.search(rf'\b{re.escape(f)}\b', R) for f in F): sys.exit('fenced row refused')
def paths(wd):
    d = glob.glob(f'{wd}/{C}/{M}/{R}-*')[0]; cm = open(d + '/cmds.txt').read()
    m = re.search(r'golden cache hit (\S+)\)', cm) or re.search(r'(/\S*slang-uhdm-goldens/[0-9a-f]+)', cm)
    return m.group(1) + '/golden.uhdm', d + '/slang.uhdm'
def recs(g, o):
    L = subprocess.run([os.environ['STRICT_CMP'], '--max', '100000', g, o], capture_output=True, text=True, errors='replace').stdout.splitlines()
    out = []
    for i, l in enumerate(L):
        m = re.match(r'#(\d+) (\w+)$', l)
        if m and i + 2 < len(L): out.append((int(m.group(1)), m.group(2), L[i+1].strip()[3:], L[i+2].strip()[3:]))
    div = out[-1][0] if any('walk diverged' in l for l in L) and out else None
    return out, div
g, po = paths(OFF); _, lo = paths(ON)
ra, da = recs(g, po); rb, db = recs(g, lo)
pool = collections.Counter(r[1:] for r in ra); byg = collections.defaultdict(list)
for r in ra: byg[(r[1], r[2])].append(r)
print(f'{C}/{M}/{R}: off {len(ra)} records div@{da}; on {len(rb)} records div@{db}')
for r in rb:
    if pool[r[1:]] > 0: pool[r[1:]] -= 1; continue
    o = byg.get((r[1], r[2]))
    tag = 'PAST-OFF-DIVERGENCE' if da is not None and r[0] >= da else ('MOVED(off ours=%s)' % o[0][3][:80].replace('\t', ' ') if o else 'NEW')
    print(f'  #{r[0]} {r[1]} {tag} | golden {r[2][:110]} | ours {r[3][:110]}'.replace('\t', ' '))
