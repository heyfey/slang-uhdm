#!/usr/bin/env python3
"""Score base/patched against golden slot by slot, on a Compare-visible payload
(+ span reported separately).  Keys that exist only on one side are reported as
MISSING / EXTRA and NEVER silently dropped."""
import sys, os, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vcen

def load(p):
    d = collections.defaultdict(list)
    for k, pay, sp in vcen.collect(p):
        d[k].append((pay, sp))
    return d

def norm(k):
    return k

def score(gold, base, pat, tag, verbose=False):
    keys = set(gold) | set(base) | set(pat)
    r = collections.Counter()
    rows = []
    for k in sorted(keys):
        g = sorted(gold.get(k, [])); b = sorted(base.get(k, [])); p = sorted(pat.get(k, []))
        if not g:
            r['NO_GOLDEN_SLOT'] += 1
            if b != p: r['NO_GOLDEN_MOVED'] += 1; rows.append(('NOGOLD-MOVED',k,g,b,p))
            continue
        gb = [x[0] for x in g]; bb = [x[0] for x in b]; pb = [x[0] for x in p]
        gs = [x[1] for x in g]; bs = [x[1] for x in b]; ps = [x[1] for x in p]
        okb, okp = gb == bb, pb == gb
        sokb, sokp = gs == bs, gs == ps
        if okb and okp: r['STILL_OK'] += 1
        elif not okb and okp: r['TO_GOLDEN'] += 1; rows.append(('TO_GOLDEN',k,gb,bb,pb))
        elif okb and not okp: r['AWAY'] += 1; rows.append(('AWAY',k,gb,bb,pb))
        else:
            if bb == pb: r['STILL_WRONG'] += 1
            else: r['MOVED_STILL_WRONG'] += 1; rows.append(('MOVED_STILL_WRONG',k,gb,bb,pb))
        # span axis
        if sokb and sokp: r['SPAN_OK'] += 1
        elif not sokb and sokp: r['SPAN_TO_GOLDEN'] += 1
        elif sokb and not sokp: r['SPAN_AWAY'] += 1; rows.append(('SPAN_AWAY',k,gs,bs,ps))
        else:
            r['SPAN_WRONG'] += 1 if bs == ps else 0
            if bs != ps: r['SPAN_MOVED_STILL_WRONG'] += 1; rows.append(('SPAN_MOVED_WRONG',k,gs,bs,ps))
    print('%-18s %s' % (tag, dict(r)))
    if verbose:
        for t,k,g,b,p in rows:
            print('   [%s] %s\n       G=%s\n       B=%s\n       P=%s' % (t,k,g,b,p))
    return r, rows

if __name__ == '__main__':
    cell = sys.argv[1]; view = sys.argv[2]
    verbose = len(sys.argv) > 3
    g = load('%s/golden_%s.uhdm' % (cell, view))
    b = load('%s/ours_BASE_%s.uhdm' % (cell, view))
    p = load('%s/ours_PAT_%s.uhdm' % (cell, view))
    score(g, b, p, os.path.basename(cell)+'/'+view, verbose)
