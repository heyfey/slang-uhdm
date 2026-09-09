#!/usr/bin/env python3
"""r10uvm226 — the three-way join behind armdelta226.sh.

  usage: tri226.py <golden.proc> <pristine.proc> <patched.proc> <armname>

Reads three `proccen226.py` listings and scores every key on both axes.  A key
absent from a side counts as a MISSING value (`<absent>`), so a cell that only
appears after the patch is scored honestly — TO-GOLDEN if it now matches
golden, STILL-WRONG if it does not, and AWAY if the patch DELETED a cell that
matched.  The FIELD axis splits each cell's payload on ' ; ' and keys by
(cell, ordinal), so one line going right -> wrong inside an otherwise-wrong
cell is convicted.
"""
import sys

ABSENT = '<absent>'


def load(p):
    d = {}
    for line in open(p):
        if not line.startswith('CELL '):
            continue
        k, _, v = line[5:].partition(' | ')
        d[k.strip()] = v.strip()
    return d


def score(g, o, q, label, out):
    to = away = still = right = 0
    for k in sorted(set(g) | set(o) | set(q)):
        gv = g.get(k, ABSENT)
        ov = o.get(k, ABSENT)
        qv = q.get(k, ABSENT)
        if gv == ABSENT and ov == ABSENT and qv == ABSENT:
            continue
        pre_ok, post_ok = ov == gv, qv == gv
        if pre_ok and post_ok:
            right += 1
        elif not pre_ok and post_ok:
            to += 1
            out.append('   %s TO-GOLDEN   %s' % (label, k))
        elif pre_ok and not post_ok:
            away += 1
            out.append('   %s AWAY        %s' % (label, k))
        else:
            still += 1
            out.append('   %s STILL-WRONG %s' % (label, k))
    return to, away, still, right


def fields(d):
    out = {}
    for k, v in d.items():
        for i, t in enumerate(v.split(' ; ')):
            out['%s#%d' % (k, i)] = t
    return out


def main():
    g, o, q, arm = (load(sys.argv[1]), load(sys.argv[2]),
                    load(sys.argv[3]), sys.argv[4])
    lines = []
    ct, ca, cs, cr = score(g, o, q, 'CELL ', lines)
    ft, fa, fsw, fr = score(fields(g), fields(o), fields(q), 'FIELD', lines)
    print('ARM %-18s CELL  to %-4d away %-4d still %-4d same %-4d'
          % (arm, ct, ca, cs, cr))
    print('ARM %-18s FIELD to %-4d away %-4d still %-4d same %-4d'
          % (arm, ft, fa, fsw, fr))
    for l in lines:
        if 'AWAY' in l or 'TO-GOLDEN' in l:
            print(l)
    print('CELLSUM %d %d %d %d' % (ct, ca, cs, cr))
    print('FIELDSUM %d %d %d %d' % (ft, fa, fsw, fr))


if __name__ == '__main__':
    main()
