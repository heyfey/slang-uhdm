#!/usr/bin/env python3
"""r11u86 scorer — ORDINAL-KEYED (r11v81's RV81-3: ts81probe's (section,name,op)
key COLLIDES when several instances share a sink parameter name, and only the
LAST is scored).  Keys on (section ORDINAL, operand index) instead, so every
cell of every section is scored.  Scores PER CELL and PER FIELD.
usage: score86.py <griddir> <tagA> <tagB> [armfilter...]
       TO = B moved to golden where A was wrong; AWAY = B left golden where A
       had it; STILL = both wrong the same way; WRONG2 = B's scored field is
       golden but another field of the cell is not; EQ = both golden."""
import sys, os, re, subprocess
PROBE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'ts81probe')
FIELDS = ('sz','ct','v','d','ts')
def probe(db):
    out = subprocess.run([PROBE, db], capture_output=True, text=True).stdout
    secs, cur, n = [], None, 0
    for l in out.splitlines():
        m = re.match(r'TOP(\w+) (\S+) (.*)', l)
        if m:
            cur = [f'{n}:{m.group(1)}:{m.group(2)}', []]; secs.append(cur); n += 1; continue
        m = re.match(r'\s+\[(\d+)\] (.*)', l)
        if m and cur is not None: cur[1].append(m.group(2).strip())
    return secs
def fields(cell):
    d = {}
    m = re.match(r'constant sz=(\S+) ct=(\S+) v=(\S*) d=(\S*) ts=(.*)', cell)
    if not m: return None
    for i,f in enumerate(FIELDS): d[f] = m.group(i+1)
    return d
def main():
    grid, ta, tb = sys.argv[1], sys.argv[2], sys.argv[3]
    filt = sys.argv[4:]
    tot = dict(TO=0, AWAY=0, STILL=0, WRONG2=0, EQ=0, SHAPE=0)
    for arm in sorted(a[2:] for a in os.listdir(grid) if a.startswith('g_')):
        if filt and arm not in filt: continue
        gd = [f'{grid}/g_{arm}/slpp_all/{x}' for x in os.listdir(f'{grid}/g_{arm}/slpp_all')
              if x.endswith('.uhdm')] if os.path.isdir(f'{grid}/g_{arm}/slpp_all') else []
        pa, pb = f'{grid}/o_{arm}_{ta}/ours.uhdm', f'{grid}/o_{arm}_{tb}/ours.uhdm'
        if not gd or not os.path.exists(pa) or not os.path.exists(pb): continue
        G, A, B = probe(gd[0]), probe(pa), probe(pb)
        c = dict(TO=0, AWAY=0, STILL=0, WRONG2=0, EQ=0, SHAPE=0)
        for gs, as_, bs in zip(G, A, B):
            for gc, ac, bc in zip(gs[1], as_[1], bs[1]):
                gf, af, bf = fields(gc), fields(ac), fields(bc)
                if gf is None or af is None or bf is None:
                    if not (gc == ac == bc): c['SHAPE'] += 1
                    continue
                agree_a = all(af[f] == gf[f] for f in FIELDS)
                agree_b = all(bf[f] == gf[f] for f in FIELDS)
                moved = [f for f in FIELDS if af[f] != bf[f]]
                if agree_a and agree_b: c['EQ'] += 1
                elif agree_b: c['TO'] += 1
                elif agree_a: c['AWAY'] += 1
                elif moved:
                    tog = [f for f in moved if bf[f] == gf[f] and af[f] != gf[f]]
                    awg = [f for f in moved if af[f] == gf[f] and bf[f] != gf[f]]
                    if awg: c['AWAY'] += 1; print(f'   AWAY {arm} {gs[0]} {gs[1].index(gc)} {awg} G={gc} A={ac} B={bc}')
                    elif tog: c['WRONG2'] += 1
                    else: c['STILL'] += 1
                else: c['STILL'] += 1
        print(f'{arm:<18} ' + ' '.join(f'{k}={v}' for k, v in c.items()))
        for k in tot: tot[k] += c[k]
    print('TOTAL  ' + '  '.join(f'{k}={v}' for k, v in tot.items()))
main()
