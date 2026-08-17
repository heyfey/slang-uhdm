#!/usr/bin/env python3
"""r10buvm12repro/cenjoin12.py — JOIN two tf_call censuses on an ID-BLIND,
ADDRESS-BLIND key and classify the CALLEE-LINK question.

    usage: cenjoin12.py <golden.cen> G <ours.cen> P [--limit N]

LHS is ALWAYS golden.  The key is (view, parent chain of kinds+names, call kind,
call name, line:col) — no object id, no address, nothing allocation-ordered.
The CELL is (link present?, link target fullname@line:col).

Classes printed:
    G=L P=L  both link, SAME target
    G=L P=X  both link, DIFFERENT target   <- a MIS-LINK, also a defect
    G=N P=N  neither links
    G=L P=N  golden links, we do NOT       <- the head's family
    G=N P=L  we link, golden does NOT      <- an OVER-LINK, must stay 0
    one-sided keys (the call object exists on one side only) are counted
    separately and are NOT this law's business.

A join that cannot report ZERO on identical inputs cannot report N on different
ones, so the golden-vs-golden calibration is the first thing the caller runs.
"""
import sys, collections

def load(path, tag):
    rows = {}
    dup = 0
    with open(path) as f:
        for ln in f:
            p = ln.split()
            if not p or p[0] != 'TC' or p[1] != tag:
                continue
            d = {}
            for tok in p[2:]:
                if '=' in tok:
                    k, v = tok.split('=', 1)
                    d[k] = v
            key = d.get('key', '')
            cell = (d.get('lnk', '0'), d.get('tgt', '-'),
                    d.get('nargs', '0'), d.get('scope', '0'),
                    d.get('home', '-'))
            if key in rows:
                dup += 1
            rows.setdefault(key, []).append(cell)
    # THE COLLISION TRAP: 120 of BuildUVMPkg's 13 083 tf_calls share a key with
    # another call (two textually identical calls at one line:col under one
    # parent, and elaborated clones).  A last-writer-wins dict silently DROPS
    # one of each pair, so every key holds the FULL MULTISET of its cells and
    # the join compares multisets -- order-blind and collision-safe.
    for k in rows:
        rows[k].sort()
    return rows, dup

def main():
    limit = 40
    if '--limit' in sys.argv:
        limit = int(sys.argv[sys.argv.index('--limit') + 1])
    g, gdup = load(sys.argv[1], sys.argv[2])
    p, pdup = load(sys.argv[3], sys.argv[4])
    print('rows: G=%d (key-collisions %d)  P=%d (key-collisions %d)'
          % (len(g), gdup, len(p), pdup))
    cls = collections.Counter()
    bad = []
    for k in set(g) | set(p):
        if k not in g:
            cls['P-only'] += len(p[k]); continue
        if k not in p:
            cls['G-only'] += len(g[k]); continue
        gv, pv = g[k], p[k]
        if len(gv) != len(pv):
            cls['ARITY-DIFF'] += 1
            bad.append(('ARITY   ', k, gv[0], pv[0]))
            continue
        for gc, pc in zip(gv, pv):
            gl, pl = gc[0] == '1', pc[0] == '1'
            if gl and pl:
                name = 'G=L P=L' if gc[1] == pc[1] else 'G=L P=X'
            elif gl:
                name = 'G=L P=N'
            elif pl:
                name = 'G=N P=L'
            else:
                name = 'G=N P=N'
            cls[name] += 1
            if name in ('G=L P=N', 'G=N P=L', 'G=L P=X'):
                bad.append((name, k, gc, pc))
    for k in sorted(cls):
        print('%-10s %d' % (k, cls[k]))
    for n, k, gv, pv in sorted(bad)[:limit]:
        print('  %-8s %s\n      G tgt=%s  P tgt=%s  nargs=%s/%s scope=%s/%s home=%s'
              % (n, k, gv[1], pv[1], gv[2], pv[2], gv[3], pv[3], gv[4]))
    print('DISAGREEING %d (shown %d)' % (len(bad), min(limit, len(bad))))

main()
