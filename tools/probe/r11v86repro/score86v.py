#!/usr/bin/env python3
"""VERIFIER re-scorer — score86.py zips the golden and ours section LISTS
positionally, so an arm where our binary emits a different NUMBER of
param_assign sections (m3_gate86 5 vs golden 6, m4_ctx86 7 vs 8, z5_home86 3 vs
2) silently compares cells against the WRONG golden section.  This aligns the
section lists with difflib on (section name, operand count) first and scores
only ALIGNED sections; unaligned ones are counted as UNPAIRED.
usage: score86v.py <griddir> <tagA> <tagB> [arms...]"""
import sys, os, re, subprocess, difflib
PROBE = '/tmp/v11u86_g/ts81probe'
FIELDS = ('sz','ct','v','d','ts')
def probe(db):
    out = subprocess.run([PROBE, db], capture_output=True, text=True).stdout
    secs, cur = [], None
    for l in out.splitlines():
        m = re.match(r'TOP(\w+) (\S+) op(\d+) n=(\d+)', l)
        if m:
            cur = [(m.group(1), m.group(2), m.group(3), m.group(4)), []]; secs.append(cur); continue
        m = re.match(r'\s+\[(\d+)\] (.*)', l)
        if m and cur is not None: cur[1].append(m.group(2).strip())
    return secs
def fields(cell):
    m = re.match(r'constant sz=(\S+) ct=(\S+) v=(\S*) d=(\S*) ts=(.*)', cell)
    return None if not m else {f: m.group(i+1) for i, f in enumerate(FIELDS)}
def align(G, A):
    sm = difflib.SequenceMatcher(None, [s[0] for s in G], [s[0] for s in A])
    out = []
    for op, i1, i2, j1, j2 in sm.get_opcodes():
        if op == 'equal':
            out += [(i1+k, j1+k) for k in range(i2-i1)]
    return out, (len(G)-len(out), len(A)-len(out))
def main():
    grid, ta, tb = sys.argv[1], sys.argv[2], sys.argv[3]
    filt = sys.argv[4:]
    tot = dict(TO=0, AWAY=0, STILL=0, WRONG2=0, EQ=0, SHAPE=0, MWRONG=0, UNPAIR=0)
    for arm in sorted(a[2:] for a in os.listdir(grid) if a.startswith('g_')):
        if filt and arm not in filt: continue
        gdir = f'{grid}/g_{arm}/slpp_all'
        gd = [f'{gdir}/{x}' for x in os.listdir(gdir) if x.endswith('.uhdm')] if os.path.isdir(gdir) else []
        pa, pb = f'{grid}/o_{arm}_{ta}/ours.uhdm', f'{grid}/o_{arm}_{tb}/ours.uhdm'
        if not gd or not os.path.exists(pa) or not os.path.exists(pb): continue
        G, A, B = probe(gd[0]), probe(pa), probe(pb)
        if [s[0] for s in A] != [s[0] for s in B]:
            print(f'{arm}: *** PRISTINE AND LAW SECTION LISTS DIFFER ***')
        pairs, (gu, au) = align(G, A)
        c = dict(TO=0, AWAY=0, STILL=0, WRONG2=0, EQ=0, SHAPE=0, MWRONG=0, UNPAIR=gu+au)
        for gi, ai in pairs:
            for gc, ac, bc in zip(G[gi][1], A[ai][1], B[ai][1]):
                gf, af, bf = fields(gc), fields(ac), fields(bc)
                if gf is None or af is None or bf is None:
                    if not (gc == ac == bc): c['SHAPE'] += 1
                    continue
                ch = [f for f in FIELDS if af[f] != bf[f]]
                bad = [f for f in ch if bf[f] != gf[f]]
                if bad:
                    c['MWRONG'] += 1
                    print(f'   MOVED-WRONG {arm} sec{gi} {bad} G={gc} P={ac} L={bc}')
                agree_a = all(af[f] == gf[f] for f in FIELDS)
                agree_b = all(bf[f] == gf[f] for f in FIELDS)
                if agree_a and agree_b: c['EQ'] += 1
                elif agree_b: c['TO'] += 1
                elif agree_a:
                    c['AWAY'] += 1
                    print(f'   AWAY {arm} sec{gi} G={gc} P={ac} L={bc}')
                elif ch:
                    tog = [f for f in ch if bf[f] == gf[f] and af[f] != gf[f]]
                    awg = [f for f in ch if af[f] == gf[f] and bf[f] != gf[f]]
                    if awg: c['AWAY'] += 1; print(f'   AWAY-F {arm} sec{gi} {awg} G={gc} P={ac} L={bc}')
                    elif tog: c['WRONG2'] += 1
                    else: c['STILL'] += 1
                else: c['STILL'] += 1
        print(f'{arm:<18} ' + ' '.join(f'{k}={v}' for k, v in c.items()))
        for k in tot: tot[k] += c[k]
    print('TOTAL  ' + '  '.join(f'{k}={v}' for k, v in tot.items()))
main()
