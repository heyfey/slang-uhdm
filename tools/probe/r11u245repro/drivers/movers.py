#!/usr/bin/env python3
"""(r11u245) movers.py <pristine sweep wd> <law sweep wd> <prediction>: the probe and downstream-lane byte movers of
two gate sweeps (md5 of every probe database and every downstream slang-lane database), each matched against the
frozen prediction by name.  The corpus movers are byteverify.sh's.  Fenced downstream paths are skipped unread
(fail-closed on $FENCED)."""
import os, re, sys, glob, hashlib
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('movers.py: source drivers/env.sh first')
P, L, PR = sys.argv[1:4]
def fenced(p): return any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F)
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except FileNotFoundError: return None
pred = {l.split('\t')[0] for l in open(PR) if l.strip()}
mov = []; n = 0
for p in sorted(glob.glob(f'{L}/probe/*.uhdm')):
    b = os.path.basename(p); n += 1
    if md5(p) != md5(f'{P}/probe/{b}'): mov.append('probe/' + b[:-5].replace('__', '/'))
for d in sorted(glob.glob(f'{L}/downstream/*/')):
    rel = os.path.relpath(d, L)
    if fenced(rel): continue
    p = d + 'slang.uhdm'
    if not os.path.exists(p): continue
    n += 1
    if md5(p) != md5(f'{P}/{rel}/slang.uhdm'): mov.append(rel)
for m in mov: print(('PREDICTED ' if m in pred else 'UNPREDICTED ') + m)
print(f'read={n} movers={len(mov)} predicted={sum(m in pred for m in mov)} unpredicted={sum(m not in pred for m in mov)}')
