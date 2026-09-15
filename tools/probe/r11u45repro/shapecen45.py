#!/usr/bin/env python3
"""r11u45/shapecen45.py — THE JUDGE-SHAPE CENSUS (the SHAPE LISTER's reader).

Why it exists: the whole-dump diff is POLLUTED by uhdm-dump's own printer when a
pass changes SHARING.  uhdm-dump prints a shared object in full the first time
and abbreviates it afterwards, and it re-prints a shared object once per
referrer, so making two parameters share ONE object changes many dump lines that
carry no judged content at all (no generated Compare reads VpiParent, and none
counts objects — RESUME.md §9).  Judging a share by dump text therefore
manufactures AWAY-GOLDEN phantoms.

This reads tslist45's output and reduces each database to a MULTISET of
JUDGE-VISIBLE facts:

    RT <vpiFullName> <vpiName> -> <kind> <loc> ranges=<n>

i.e. every ref_typespec keyed by the names the judge reads, mapped to the KIND,
SPAN and RANGE COUNT of the typespec it actually resolves to.  Parenthood,
object counts and print order — the three things the printer confuses — are not
in the key.  `loc` is kept because two typespecs at different spans are
different objects to a reader even though Compare ignores the location; it is
reported separately so a location-only delta can be told from a content delta.

    usage: shapecen45.py <golden.tslist> <before.tslist> <after.tslist>
"""
import collections
import re
import sys


def load(path):
    ts, rt = {}, []
    for line in open(path):
        m = re.match(r'TS #(\d+) (\S+) loc=(\S+) ranges=(-?\d+) name=(\S*) ', line)
        if m:
            ts[m.group(1)] = (m.group(2), m.group(3), m.group(4), m.group(5))
            continue
        m = re.match(r'RT #(\d+) name=(\S*) full=(\S*) -> ts#(-?\d+) ', line)
        if m:
            rt.append((m.group(3), m.group(2), m.group(4)))
    out = collections.Counter()
    for full, name, tgt in rt:
        k = ts.get(tgt, ('<null>', '-', '-', '-'))
        out[f'RT {full} {name} -> {k[0]} {k[1]} ranges={k[2]} tsname={k[3]}'] += 1
    return out


def diffset(g, o):
    d = collections.Counter()
    for k in set(g) | set(o):
        n = o[k] - g[k]
        if n:
            d[k] = n
    return d


g, b, a = (load(p) for p in sys.argv[1:4])
db, da = diffset(g, b), diffset(g, a)
to = sum(max(0, abs(v) - abs(da.get(k, 0))) for k, v in db.items())
away = sum(max(0, abs(v) - abs(db.get(k, 0))) for k, v in da.items())
print(f'BEFORE differing-facts={sum(abs(v) for v in db.values())}  '
      f'AFTER differing-facts={sum(abs(v) for v in da.values())}  '
      f'TO-GOLDEN={to}  AWAY-GOLDEN={away}')
for k in sorted(set(db) | set(da)):
    vb, va = db.get(k, 0), da.get(k, 0)
    if vb != va:
        print(f'  [{vb:+d} -> {va:+d}] {k}')
