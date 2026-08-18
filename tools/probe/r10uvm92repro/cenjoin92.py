#!/usr/bin/env python3
"""r10uvm92 — golden-vs-ours join of two ct92cen outputs.  MEASUREMENT-ONLY.

The join key is the SPAN (line:col-endline:endcol) plus the hier_path NAME's
SHAPE, because our databases do not always carry a VpiFile on a hier_path and
keying on a field one side leaves empty would silently drop every row.  Rows
are MULTISETS per key (the same span repeats once per elaborated instance).

Prints, per differing key: golden NAME(s), our NAME(s), and OUR OWN TREE's
`ExprEval::prettyPrint` of the index (the PP column) -- so a key where
goldenNAME == ourPP is a key THIS LAW REACHES, and one where they differ is a
residue that needs its own decode.
Usage: cenjoin92.py <g.cen> <o.cen> [--verbose]
"""
import re, sys, collections

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if '\t' not in ln: continue
        k, rest = ln.split('\t', 1)
        span = k.split('|', 1)[1] if '|' in k else k
        nm = re.search(r'NAME=([^\t]*)', rest)
        cells = re.search(r'CELLS=([^\t]*)', rest)
        d[span].append((nm.group(1) if nm else '', cells.group(1) if cells else ''))
    return d

g, o = load(sys.argv[1]), load(sys.argv[2])
verbose = '--verbose' in sys.argv
same = diff = gonly = oonly = 0
reach = unreach = 0
sigs = collections.Counter()
for k in sorted(set(g) | set(o)):
    G, O = sorted(set(g.get(k, []))), sorted(set(o.get(k, [])))
    if not O: gonly += 1; continue
    if not G: oonly += 1; continue
    gn, on = [x[0] for x in G], [x[0] for x in O]
    if gn == on: same += 1; continue
    diff += 1
    # what would OUR name be if the index rendered through prettyPrint of OUR
    # own tree?  substitute each BRK in our name by its PP.
    pred = []
    for nm, cells in O:
        t = nm
        for c in cells.split(';'):
            mb = re.search(r'BRK=(\[.*\]):PP=(\[.*\]):PPM=', c)
            if mb: t = t.replace(mb.group(1), mb.group(2), 1)
        pred.append(t)
    ok = sorted(set(pred)) == gn
    if ok: reach += 1
    else: unreach += 1
    sigs[(tuple(gn), tuple(on), tuple(sorted(set(pred))), ok)] += 1
    if verbose:
        print(f"{'REACH ' if ok else 'RESIDUE'} {k}\n   G    {gn}\n   O    {on}\n   pred {sorted(set(pred))}")
print(f"-- keys={len(set(g)|set(o))} SAME={same} DIFF={diff} "
      f"(REACHED-BY-PP={reach} RESIDUE={unreach}) ONLY-GOLDEN={gonly} ONLY-OURS={oonly}")
for (gn, on, pr, ok), n in sigs.most_common(60):
    print(f"  [{n:4}] {'REACH  ' if ok else 'RESIDUE'} G={list(gn)}  O={list(on)}  pred={list(pr)}")
