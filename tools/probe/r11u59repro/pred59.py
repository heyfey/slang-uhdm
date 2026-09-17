#!/usr/bin/env python3
# r11u59 — THE A-PRIORI MOVER PREDICTOR, and the two censuses.
# Measurement only; the judge is uhdm-cmp.
#
# THE PREDICTION (the mask half, R2).  § patElabNoMask59 removes two writes:
# `VpiValue("UINT:"+v&mask)` and `VpiDecompile(v&mask)`.  A cell MOVES exactly
# when the mask was not the identity there.  That is invisible in our pristine
# database alone (post-mask the value always fits), so the predictor joins the
# PRISTINE cell to the GOLDEN cell and inverts the mask arithmetic:
#
#     a cell is a PREDICTED MOVER  <=>  ours is a constant with vpiConstType 9
#         and 0 < vpiSize < 64, golden's decompile parses as an integer g,
#         ours' decompile parses as an integer u, and
#             u == g mod 2**size   and   u != g
#
# which is precisely "our value is golden's value with the member-width mask
# applied".  Negative golden values are covered by the modulus (Python's % is
# the two's-complement residue), which is the wa3_signed face.
#
# THE GOLDEN-VS-GOLDEN CENSUS runs FIRST and answers the corpus question the
# brief asks: does ANY corpus package pattern element carry a value wider than
# the vpiSize it sits at?  cen59 marks those OVERWIDE.
#
# THE FLATTEN CENSUS (R0) joins the SHAPE lines: a pattern where golden reads
# FLAT and ours reads TAGGED is one completed-walk cell of R0; per-row residue
# arithmetic is printed so the next pass can rank the rows.
#
# Cells are joined as a MULTISET on (view, owner, param, membertag, idx) — no
# id, no span, no fullname; none of those is read by any generated Compare.
#
# usage: pred59.py <gold.txt> <ours.txt> [--flat] [--quiet]
import sys, re
from collections import defaultdict


def load(path):
    cells, shapes = {}, {}
    for line in open(path, errors='replace'):
        f = line.split()
        if not f:
            continue
        if f[0] == 'CELL':
            # CELL <row> <view> <owner> <param> <mtag> idx= kind= size= ct= val= dec=
            row, view, owner, param, mtag = f[1], f[2], f[3], f[4], f[5]
            d = dict(x.split('=', 1) for x in f[6:] if '=' in x)
            key = (row, view, owner, param, mtag, d.get('idx', '?'))
            cells[key] = d
        elif f[0] == 'SHAPE':
            row, view, owner, param, shape = f[1], f[2], f[3], f[4], f[5]
            d = dict(x.split('=', 1) for x in f[6:] if '=' in x)
            shapes[(row, view, owner, param)] = (shape, d)
    return cells, shapes


def asint(s):
    if s in (None, '-', ''):
        return None
    try:
        return int(s, 10)
    except ValueError:
        return None


def main():
    g, o = sys.argv[1], sys.argv[2]
    want_flat = '--flat' in sys.argv[3:]
    quiet = '--quiet' in sys.argv[3:]
    gc, gs = load(g)
    oc, os_ = load(o)

    # ---- golden-vs-golden first: the OVERWIDE census ----
    ow = []
    for line in open(g, errors='replace'):
        if line.rstrip().endswith('OVERWIDE'):
            f = line.split()
            ow.append((f[1], f[2], f[3], f[4], f[5]))
    owe = [c for c in ow if c[1].startswith('elab')]
    print('GOLDEN-CENSUS cells=%d overwide=%d overwide_elab=%d rows_overwide=%d'
          % (len(gc), len(ow), len(owe), len({c[0] for c in ow})))
    if not quiet:
        for c in sorted(set(ow))[:40]:
            print('  GOLD-OVERWIDE %s %s %s %s %s' % c)

    # ---- the a-priori mover prediction ----
    gpos = {}
    for k, d in gc.items():
        gpos[(k[0], k[1], k[2], k[3], k[5])] = d
    movers = defaultdict(list)
    cand = set()
    for k, od in oc.items():
        if od.get('kind') != 'constant' or od.get('ct') != '9':
            continue
        sz = asint(od.get('size'))
        if sz is None or sz <= 0 or sz >= 64:
            continue
        # CANDIDATE = every cell the arm's own filter can reach (a UINT-typed
        # constant element at a sub-64 size).  The MOVER set below is a subset
        # of this; the widest sound containment check for the byteverify movers
        # is against CANDIDATE, because the mover rule assumes our substituted
        # value and golden's agree numerically before the mask.
        if k[1].startswith('elab'):
            cand.add(k[0])
        gd = gc.get(k)
        if gd is None:
            # POSITIONAL FALLBACK.  Golden's elaborated listing is FLAT
            # (untagged, positional) wherever the producer's walk COMPLETED, so
            # a tag join misses exactly the cells R0 names.  Fall back to the
            # element INDEX, which both shapes carry.
            gd = gpos.get((k[0], k[1], k[2], k[3], k[5]))
        if gd is None:
            continue
        u = asint(od.get('dec'))
        gv = asint(gd.get('dec'))
        if u is None or gv is None:
            continue
        if u != gv and u == (gv % (1 << sz)):
            movers[k[0]].append((k, gv, u, sz))
    print('PREDICT rows=%d cells=%d candidate_rows=%d'
          % (len(movers), sum(len(v) for v in movers.values()), len(cand)))
    for r in sorted(cand):
        print('  CANDROW %s' % r)
    for row in sorted(movers):
        for (k, gv, u, sz) in movers[row]:
            print('  MOVER %s %s %s %s %s idx=%s size=%d ours=%d golden=%d'
                  % (k[0], k[1], k[2], k[3], k[4], k[5], sz, u, gv))

    # ---- the FLATTEN census (R0) ----
    if want_flat:
        flat_g_tag_o, both, tot = [], 0, 0
        for k, (sh, d) in gs.items():
            if not k[1].startswith('elab'):
                continue
            tot += 1
            osh = os_.get(k)
            if osh is None:
                continue
            both += 1
            if sh == 'FLAT' and osh[0] == 'TAGGED':
                flat_g_tag_o.append((k, d.get('n'), osh[1].get('n')))
        per = defaultdict(int)
        for (k, gn, on) in flat_g_tag_o:
            per[k[0]] += 1
        print('FLATTEN-CENSUS elab_patterns_golden=%d joined=%d '
              'GOLDFLAT_OURSTAGGED=%d rows=%d' %
              (tot, both, len(flat_g_tag_o), len(per)))
        for row in sorted(per, key=lambda r: -per[r]):
            print('  R0ROW %s cells=%d' % (row, per[row]))
        for (k, gn, on) in sorted(flat_g_tag_o)[:60]:
            print('  R0CELL %s %s %s %s goldn=%s oursn=%s'
                  % (k[0], k[1], k[2], k[3], gn, on))


main()
