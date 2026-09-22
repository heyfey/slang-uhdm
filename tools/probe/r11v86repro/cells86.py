#!/usr/bin/env python3
"""VERIFIER per-cell, per-field printer.  For every operand cell of every arm
given, prints golden / pristine / law on the FIVE fields and flags
MOVED-WRONG: a field the law CHANGED whose new value is NOT golden's."""
import sys, os, re, subprocess
PROBE = '/tmp/v11u86_g/ts81probe'
FIELDS = ('sz','ct','v','d','ts')
def probe(db):
    out = subprocess.run([PROBE, db], capture_output=True, text=True).stdout
    secs, cur, n = [], None, 0
    for l in out.splitlines():
        m = re.match(r'TOP(\w+) (\S+) (.*)', l)
        if m:
            cur = [f'{n}:{m.group(1)}:{m.group(2)}:{m.group(3)}', []]; secs.append(cur); n += 1; continue
        m = re.match(r'\s+\[(\d+)\] (.*)', l)
        if m and cur is not None: cur[1].append(m.group(2).strip())
    return secs
def fields(cell):
    m = re.match(r'constant sz=(\S+) ct=(\S+) v=(\S*) d=(\S*) ts=(.*)', cell)
    return None if not m else {f: m.group(i+1) for i, f in enumerate(FIELDS)}
grid = sys.argv[1]
mw = 0
for arm in sys.argv[2:]:
    gdir = f'{grid}/g_{arm}/slpp_all'
    gd = [f'{gdir}/{x}' for x in os.listdir(gdir) if x.endswith('.uhdm')]
    G, A, B = probe(gd[0]), probe(f'{grid}/o_{arm}_pris/ours.uhdm'), probe(f'{grid}/o_{arm}_lawx/ours.uhdm')
    print(f'==== {arm}  sections g={len(G)} p={len(A)} l={len(B)}')
    for gs, as_, bs in zip(G, A, B):
        print(f'  -- {gs[0]}')
        for i, (gc, ac, bc) in enumerate(zip(gs[1], as_[1], bs[1])):
            gf, af, bf = fields(gc), fields(ac), fields(bc)
            if not (gf and af and bf):
                print(f'   [{i}] SHAPE g={gc} p={ac} l={bc}'); continue
            ch = [f for f in FIELDS if af[f] != bf[f]]
            bad = [f for f in ch if bf[f] != gf[f]]
            tag = 'MOVED-WRONG' if bad else ('moved' if ch else '')
            if bad: mw += 1
            st = ''.join(f' {f}[G={gf[f]}|P={af[f]}|L={bf[f]}]' for f in FIELDS if not (gf[f]==af[f]==bf[f]))
            print(f'   [{i}] {tag:<11}{st}')
print(f'MOVED-WRONG CELLS = {mw}')
