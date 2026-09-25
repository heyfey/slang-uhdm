#!/usr/bin/env python3
"""attrib.py: every byte mover of the final sweep (evidence/sweeps/byteverify_*.txt) re-run with R11U168_OFF=1
(r11u166 alone, /tmp/r11u168_atA), R11U166_OFF=1 (r11u168 alone, atB) and both (atC); bytes compared with the
pristine (swP) and final (swF) sweeps.  Fail-closed on FENCED (the movers list never holds a fenced row: the
byteverify inputs are fence-clean mirrors)."""
import glob, hashlib, os, sys
F = os.environ.get('FENCED', '').split(); assert len(F) == 4, 'FENCED unset'
E = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'evidence', 'sweeps')
def md(p): return hashlib.md5(open(p, 'rb').read()).hexdigest()[:10]
def db(root, c, m, t):
    g = glob.glob(f'{root}/{c}/{m}/{t}-*/slang.uhdm'); return md(g[0]) if g else None
print('row law 166only 168only alloff moved_by')
for f in ('surelog', 'uhdm2rtlil'):
    for l in open(f'{E}/byteverify_{f}.txt'):
        if not l.startswith('MOVER '): continue
        m, d = l.split()[1][2:].split('/')[:2]; t = d.rsplit('-', 1)[0]
        assert t not in F
        P, L = db('/tmp/r11u168_swP', f, m, t), db('/tmp/r11u168_swF', f, m, t)
        A, B, C = (db(f'/tmp/r11u168_at{x}', f, m, t) for x in 'ABC')
        lab = lambda X: '=law' if X == L else ('=pris' if X == P else 'other')
        who = [n for n, X in (('r11u166', A), ('r11u168', B)) if X != P]
        print(f'{f}/{m}/{t} {"moved" if L != P else "same"} 166only{lab(A)} 168only{lab(B)} alloff={"PRISTINE" if C == P else "DIFFERS"} moved_by={"+".join(who)}')
