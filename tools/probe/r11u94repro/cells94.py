#!/usr/bin/env python3
"""r11u94 CELL LISTER — the SHAPE LISTER that rides beside the scorer.  Prints
every ALIGNED pattern-operand cell of every arm as `golden | tagA | tagB`, with
the disagreeing fields named, so a claim about one cell can be read without
re-deriving it from the scorer's counters.  Alignment is score87v.py's (difflib
on the section list), so a section our binary does not emit is reported as
UNPAIRED rather than silently compared against the wrong golden section.
usage: cells94.py <griddir> <tagA> <tagB> [arms...]"""
import sys, os, re, subprocess, difflib
PROBE = os.environ.get('TS87PROBE',
                       os.path.join(os.path.dirname(os.path.abspath(__file__)), 'ts87probe'))
FIELDS = ('sz', 'ct', 'v', 'd', 'ts')


def probe(db):
    out = subprocess.run([PROBE, db], capture_output=True, text=True).stdout
    secs, cur = [], None
    for l in out.splitlines():
        m = re.match(r'TOP(\w+) (\S+) op(\d+) n=(\d+)', l)
        if m:
            cur = [(m.group(1), m.group(2), m.group(3), m.group(4)), []]
            secs.append(cur)
            continue
        m = re.match(r'\s+\[(\d+)\] (.*)', l)
        if m and cur is not None:
            cur[1].append(m.group(2).strip())
    return secs


def fields(cell):
    m = re.match(r'constant sz=(\S+) ct=(\S+) v=(\S*) d=(\S*) ts=(.*)', cell)
    return None if not m else {f: m.group(i + 1) for i, f in enumerate(FIELDS)}


def align(G, A):
    sm = difflib.SequenceMatcher(None, [s[0] for s in G], [s[0] for s in A])
    out = []
    for op, i1, i2, j1, j2 in sm.get_opcodes():
        if op == 'equal':
            out += [(i1 + k, j1 + k) for k in range(i2 - i1)]
    return out, (len(G) - len(out), len(A) - len(out))


def main():
    grid, ta, tb = sys.argv[1], sys.argv[2], sys.argv[3]
    filt = sys.argv[4:]
    for arm in sorted(a[2:] for a in os.listdir(grid) if a.startswith('g_')):
        if filt and arm not in filt:
            continue
        gdir = f'{grid}/g_{arm}/slpp_all'
        gd = [f'{gdir}/{x}' for x in os.listdir(gdir) if x.endswith('.uhdm')] \
            if os.path.isdir(gdir) else []
        pa, pb = f'{grid}/o_{arm}_{ta}/ours.uhdm', f'{grid}/o_{arm}_{tb}/ours.uhdm'
        if not gd or not os.path.exists(pa) or not os.path.exists(pb):
            continue
        G, A, B = probe(gd[0]), probe(pa), probe(pb)
        pairs, (gu, au) = align(G, A)
        print(f'=== {arm}   sections G={len(G)} ours={len(A)} aligned={len(pairs)} '
              f'UNPAIRED g={gu} ours={au}')
        for gi, ai in pairs:
            print('  SEC ' + ' '.join(G[gi][0]))
            for k, (gc, ac, bc) in enumerate(zip(G[gi][1], A[ai][1], B[ai][1])):
                gf, af, bf = fields(gc), fields(ac), fields(bc)
                tag = ''
                if gf and af and bf:
                    da = [f for f in FIELDS if af[f] != gf[f]]
                    db = [f for f in FIELDS if bf[f] != gf[f]]
                    tag = f'   Pbad={",".join(da) or "-"} Lbad={",".join(db) or "-"}'
                print(f'   [{k}] G {gc}')
                print(f'       P {ac}')
                print(f'       L {bc}{tag}')


main()
