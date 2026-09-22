#!/usr/bin/env python3
"""r11u96 PER-FIELD pattern-cell scorer — `score87v.py`'s alignment with
`nda94.py`'s per-FIELD verdict.

`score87v.py` scores a `'{...}` pattern cell as a whole tuple.  LAW C writes
exactly ONE of a cell's five fields (`ts`), and the concatenation cells carry
a SECOND, older disagreement on `ct`/`v`/`d` (golden renders a concatenation
`BIN:00010010` where we write `UINT:18` — r11v94's RV94-6 neighbourhood), so
a whole-tuple score reads every one of those cells `WRONG2` and shows nothing.
This scorer names the field, exactly as `nda94.py` does for the
net-decl-assign road and for the same reason.

usage: score96f.py <griddir> <tagA> <tagB> [arms...]
       score96f.py --field ts <griddir> <tagA> <tagB> [arms...]
"""
import sys
import os
import re
import subprocess
import difflib

PROBE = os.environ.get('TS87PROBE', 'ts87probe')
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
    av = sys.argv[1:]
    only = None
    if av and av[0] == '--field':
        only, av = av[1], av[2:]
    grid, ta, tb = av[0], av[1], av[2]
    filt = av[3:]
    flds = (only,) if only else FIELDS
    TOT = dict(TO=0, AWAY=0, STILL=0, EQ=0, MWRONG=0, UNPAIR=0)
    for arm in sorted(a[2:] for a in os.listdir(grid) if a.startswith('g_')):
        if filt and arm not in filt:
            continue
        gdir = f'{grid}/g_{arm}/slpp_all'
        gd = [f'{gdir}/{x}' for x in os.listdir(gdir) if x.endswith('.uhdm')] \
            if os.path.isdir(gdir) else []
        pa = f'{grid}/o_{arm}_{ta}/ours.uhdm'
        pb = f'{grid}/o_{arm}_{tb}/ours.uhdm'
        if not gd or not os.path.exists(pa) or not os.path.exists(pb):
            continue
        G, A, B = probe(gd[0]), probe(pa), probe(pb)
        pairs, (gu, au) = align(G, A)
        s = dict(TO=0, AWAY=0, STILL=0, EQ=0, MWRONG=0, UNPAIR=gu + au)
        for gi, ai in pairs:
            for gc, ac, bc in zip(G[gi][1], A[ai][1], B[ai][1]):
                gf, af, bf = fields(gc), fields(ac), fields(bc)
                if not (gf and af and bf):
                    continue
                for f in flds:
                    ag, bg = af[f] == gf[f], bf[f] == gf[f]
                    if ag and bg:
                        s['EQ'] += 1
                    elif not ag and bg:
                        s['TO'] += 1
                    elif ag and not bg:
                        s['AWAY'] += 1
                        s['MWRONG'] += 1
                    else:
                        s['STILL'] += 1
                        if af[f] != bf[f]:
                            s['MWRONG'] += 1
        print('%-20s ' % arm + '  '.join('%s=%d' % (k, s[k])
                                         for k in ('TO', 'AWAY', 'STILL',
                                                   'EQ', 'MWRONG', 'UNPAIR')))
        for k in TOT:
            TOT[k] += s[k]
    print('TOTAL%s  ' % ('[%s]' % only if only else '') +
          '  '.join('%s=%d' % (k, TOT[k])
                    for k in ('TO', 'AWAY', 'STILL', 'EQ', 'MWRONG',
                              'UNPAIR')))


main()
