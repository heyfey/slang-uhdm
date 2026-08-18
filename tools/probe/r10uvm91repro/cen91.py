#!/usr/bin/env python3
"""r10uvm91 — the DEPTH-KEYED CENSUS JOIN.  MEASUREMENT-ONLY.

Joins two `ct91cen` outputs on the (class, SITE) key and reports, in order:
  * the tally of KIND / NAME / COUNT / MISSING disagreements,
  * every PRISTINE-RIGHT -> PATCHED-WRONG cell BY NAME when three files are
    given (golden, pristine, patched) — the check that caught this pass's own
    `typedef T tab_t[string];` regression before any gate ran,
  * the remaining NAME disagreements of a chosen typespec KIND.

  usage: cen91.py <golden.cen> <ours.cen> [<patched.cen>] [--kind=int_typespec]

LHS is ALWAYS golden.
"""
import re, sys, collections

def load(fn):
    d = {}
    for l in open(fn, errors='replace'):
        p = [x.strip() for x in l.rstrip('\n').split('|')]
        if len(p) < 3:
            continue
        m = re.match(r"(\S+)\s+'([^']*)'\s+@(\S+)\s+o(\d+)", p[2])
        v = (m.group(1), m.group(2), m.group(3), m.group(4)) if m else (p[2], '', '', '')
        d.setdefault((p[0], p[1]), []).append(v)
    return d

def tally(g, o, tag):
    n = collections.Counter()
    for k in sorted(set(g) | set(o)):
        gv, ov = g.get(k), o.get(k)
        if gv is None or ov is None:
            n['MISSING'] += 1; continue
        if len(gv) != len(ov):
            n['COUNT'] += 1; continue
        for a, b in zip(gv, ov):
            if a[0] != b[0]: n['KIND'] += 1
            elif a[1] != b[1]: n['NAME'] += 1
            elif a[2] != b[2]: n['SPAN'] += 1
    print(tag, dict(n))

def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    kind = next((a.split('=', 1)[1] for a in sys.argv[1:] if a.startswith('--kind=')), None)
    g = load(args[0]); o = load(args[1])
    tally(g, o, 'OURS  vs golden:')
    if len(args) > 2:
        pa = load(args[2])
        tally(g, pa, 'PATCH vs golden:')
        bad = 0
        for k in sorted(set(g) & set(o) & set(pa)):
            gv, rv, av = g[k], o[k], pa[k]
            if len(gv) != len(rv) or len(gv) != len(av):
                if len(gv) == len(rv) and len(gv) != len(av):
                    print('  COUNT REGRESSION', k); bad += 1
                continue
            for a, b, c in zip(gv, rv, av):
                if (a[0], a[1]) == (b[0], b[1]) and (a[0], a[1]) != (c[0], c[1]):
                    print(f'  REGRESSION {k[0]} | {k[1]} | G {a[:2]} -> PAT {c[:2]}'); bad += 1
        print('pristine-right->patched-wrong:', bad)
        o = pa
    if kind:
        n = 0
        for k in sorted(set(g) & set(o)):
            gv, ov = g[k], o[k]
            if len(gv) != len(ov):
                continue
            for a, b in zip(gv, ov):
                if a[0] == b[0] == kind and a[1] != b[1]:
                    print(f'  LEFT {k[0]} | {k[1]} | G {a[:2]} OURS {b[:2]}'); n += 1
        print(f'remaining {kind} NAME disagreements:', n)

main()
