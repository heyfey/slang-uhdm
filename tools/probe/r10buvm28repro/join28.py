#!/usr/bin/env python3
"""r10buvm27 census join — MEASUREMENT ONLY.  Golden LHS always.

Joins ct95cen rows of a golden database against ours on the SPAN (multiset),
and classifies every span where the two sides disagree.

  KEEP_G_FOLD_O : golden keeps the type-query CALL, we folded    -> we over-fire
  FOLD_G_KEEP_O : golden FOLDED, we kept the CALL                -> the head family
  VALUE         : both folded, the decompile differs
  OTHER         : any other asymmetry (count mismatch etc.)
"""
import sys, os, glob, collections

def load(p):
    d = collections.defaultdict(list)
    if not os.path.exists(p): return d
    for line in open(p):
        line = line.rstrip('\n')
        if not line: continue
        f = line.split('\t')
        if len(f) < 6: continue
        # KEY on the SPAN ALONE: our databases leave VpiFile EMPTY on many
        # objects (a known emitter fact), so a file-qualified key would split
        # every such cell into a G-only row and an O-only row.  The file name
        # travels as a trailing attribute instead.  A basename never contains
        # a colon, so everything up to the FIRST colon is the file.
        sp = f[0]
        i = sp.find(':')
        fn, key = sp[:i], sp[i + 1:]
        d[key].append(tuple(f[1:]) + (fn,))
    return d

def classify(g, o):
    gk = collections.Counter(x[0] for x in g)
    ok = collections.Counter(x[0] for x in o)
    if gk['CALL'] and not ok['CALL'] and ok['CONST']: return 'FOLD_G_KEEP_O' if False else 'KEEP_G_FOLD_O'
    if ok['CALL'] and not gk['CALL'] and gk['CONST']: return 'FOLD_G_KEEP_O'
    if gk['CONST'] and ok['CONST'] and not gk['CALL'] and not ok['CALL']: return 'VALUE'
    return 'OTHER'

def main():
    outdir = sys.argv[1]
    verbose = '--verbose' in sys.argv
    only = None
    for a in sys.argv[2:]:
        if not a.startswith('--'): only = a
    tot = collections.Counter()
    rows = collections.Counter()
    detail = collections.Counter()
    for gp in sorted(glob.glob(os.path.join(outdir, '*.g'))):
        key = os.path.basename(gp)[:-2]
        if only and only not in key: continue
        op = gp[:-2] + '.o'
        G = load(gp); O = load(op)
        spans = set(G) | set(O)
        for sp in sorted(spans):
            # Only the JUDGED shape is compared: KIND ($ call kept vs folded
            # constant) and the folded VALUE.  Carrier / owner / file travel
            # for inspection only (our VpiFile is often empty, and no generated
            # Compare reads VpiParent).
            g = sorted((x[0], x[1]) for x in G.get(sp, []))
            o = sorted((x[0], x[1]) for x in O.get(sp, []))
            gfull = sorted(G.get(sp, [])); ofull = sorted(O.get(sp, []))
            hascall = any(x[0] == 'CALL' for x in gfull + ofull)
            hassrc = any(len(x) > 5 and x[5] == 'SRC$' for x in gfull + ofull)
            if not hascall and not hassrc:
                # Out of the type-query scope, but a DISAGREEMENT here is still
                # worth counting: it is the blind spot a macro-body fold would
                # hide in (the UVM head's own span reads SRC-).
                tot['OUT_OF_SCOPE'] += 1
                if g != o:
                    tot['OUT_OF_SCOPE_DIFF'] += 1
                    detail['OOS | G=%s | O=%s' % (
                        ';'.join('%s:%s' % (x[0], x[1]) for x in g) or '<none>',
                        ';'.join('%s:%s' % (x[0], x[1]) for x in o) or '<none>')] += 1
                continue
            if g == o:
                tot['SAME'] += 1
                continue
            c = classify(g, o)
            tot[c] += 1
            gs = ';'.join('%s:%s' % (x[0], x[1]) for x in g) or '<none>'
            os_ = ';'.join('%s:%s' % (x[0], x[1]) for x in o) or '<none>'
            carrier = (gfull[0][3] if gfull else (ofull[0][3] if ofull else '-'))
            argk = (gfull[0][2] if gfull else (ofull[0][2] if ofull else '-'))
            detail['%s | G=%s | O=%s | ARG=%s CARR=%s' % (c, gs, os_, argk, carrier)] += 1
            rows['%s\t%s' % (c, key)] += 1
            if verbose:
                print('%-14s %-40s %-46s G=%-34s O=%s' % (c, key, sp, gs, os_))
    print('--- totals ---')
    for k, v in sorted(tot.items(), key=lambda kv: -kv[1]):
        print('%-16s %d' % (k, v))
    print('--- per test ---')
    for k, v in sorted(rows.items(), key=lambda kv: -kv[1])[:40]:
        print('%6d  %s' % (v, k))
    print('--- shapes ---')
    for k, v in sorted(detail.items(), key=lambda kv: -kv[1])[:40]:
        print('%6d  %s' % (v, k))

main()
