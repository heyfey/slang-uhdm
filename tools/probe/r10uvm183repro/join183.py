#!/usr/bin/env python3
"""r10uvm183 — the foreach census JOIN.  MEASUREMENT ONLY; the official
uhdm-cmp is the judge.  LHS is ALWAYS golden, RHS is ALWAYS ours.

A corpus database holds every VIEW of every package in one file, so a source
span names SEVERAL cells.  The join is therefore a MULTISET join (a
last-writer dict would silently drop rows — RESUME.md §9):

  key   = (line:col, enclosing tf kind:name)
  value = the MULTISET of the cell's compared face:
            (ARR object kind+name, ARR TYPESPEC kind+name+span, INSTANCE
             kind:name)
          with the owning-scope UhdmId and the package-instance UhdmId
          STRIPPED — ids are per-database and join nothing — and the FILE
          stripped from every span, because our objects carry an empty
          vpiFile and Surelog's carry a path.

Columns, per row-mode and in total:

  DEGRADE-TOWARD  golden degrades (unsupported_typespec), pristine resolves,
                  patched == golden
  MUST-STAY-AWAY  golden RESOLVES and the patch made us degrade  (must be 0)
  MOVED-WRONG     the cell moved and did not land on golden
  TOWARD-OTHER    moved onto golden on a face that is not the degrade
  untouched       identical before and after

Usage:  join183.py <outdir-of-cenrun183> [--pristine-only]
"""
import collections
import glob
import os
import re
import sys


def norm(cell):
    """strip per-database ids from a census row's value half."""
    cell = re.sub(r'#\d+', '', cell)
    return cell


def read(path):
    """-> {key: Counter(value)}"""
    out = collections.defaultdict(collections.Counter)
    if not os.path.exists(path):
        return None
    with open(path) as f:
        for line in f:
            p = line.rstrip('\n').split('\t')
            if not p or p[0] != 'FE':
                continue
            # FE  line:col  tfkind:tfname  scope  ARR=  ARRTS=  INST=  LV=
            key = (p[1], p[2])
            val = norm('\t'.join([p[4], p[5], p[6]]))
            out[key][val] += 1
    return out


def diff(a, b):
    """multiset difference over the union of keys -> list of (key, only_a, only_b)"""
    res = []
    for k in sorted(set(a) | set(b)):
        ca, cb = a.get(k, collections.Counter()), b.get(k, collections.Counter())
        if ca == cb:
            continue
        res.append((k, ca - cb, cb - ca))
    return res


def main():
    outdir = sys.argv[1]
    pristine_only = '--pristine-only' in sys.argv
    rows = []
    with open(os.path.join(outdir, 'rows.txt')) as f:
        for line in f:
            mode, name = line.split()
            rows.append((mode, name))
    tot = collections.Counter()
    ndeg = 0
    for mode, name in rows:
        g = read(os.path.join(outdir, '%s.%s.golden.tsv' % (mode, name)))
        p = read(os.path.join(outdir, '%s.%s.pris.tsv' % (mode, name)))
        q = None if pristine_only else read(
            os.path.join(outdir, '%s.%s.pat.tsv' % (mode, name)))
        if g is None or p is None:
            print('%-10s %-14s MISSING' % (mode, name))
            continue
        keys = sorted(set(g) | set(p) | (set(q) if q else set()))
        c = collections.Counter()
        deg_cells = []
        for k in keys:
            cg = g.get(k, collections.Counter())
            cp = p.get(k, collections.Counter())
            cq = q.get(k, collections.Counter()) if q is not None else None
            # every value present in golden but not pristine, split by whether
            # golden's copy is a degrade (unsupported_typespec array typespec)
            gp_only = cg - cp
            pg_only = cp - cg
            deg = sum(v for kk, v in gp_only.items()
                      if 'ARRTS=unsupported_typespec' in kk)
            res = sum(v for kk, v in pg_only.items()
                      if 'ARRTS=unsupported_typespec' not in kk)
            if deg and res:
                deg_cells.append((k, gp_only, pg_only))
            if cq is None:
                if cg == cp:
                    c['untouched'] += 1
                elif deg:
                    c['GOLDEN-DEGRADES-WE-RESOLVE'] += 1
                else:
                    c['other-disagreement'] += 1
                continue
            if cp == cq:
                c['untouched'] += 1
            elif cq == cg:
                if deg:
                    c['DEGRADE-TOWARD'] += 1
                else:
                    c['TOWARD-OTHER'] += 1
            else:
                # did we take a cell golden RESOLVES and make it degrade?
                away = sum(v for kk, v in (cq - cp).items()
                           if 'ARRTS=unsupported_typespec' in kk and
                           (cg - cp)[kk] == 0)
                if away:
                    c['MUST-STAY-AWAY'] += 1
                else:
                    c['MOVED-WRONG'] += 1
        ndeg += len(deg_cells)
        tot.update(c)
        print('%-10s %-14s cells=%-5d %s' %
              (mode, name, len(keys),
               '  '.join('%s=%d' % (k, v) for k, v in sorted(c.items()))))
        for k, ga, pa in deg_cells:
            print('    GOLDEN-DEGRADES @%s in %s' % (k[0], k[1]))
            for kk, v in sorted(ga.items()):
                print('        golden x%d  %s' % (v, kk))
            for kk, v in sorted(pa.items()):
                print('        ours   x%d  %s' % (v, kk))
    print('TOTAL %s   degrade-cells=%d' %
          ('  '.join('%s=%d' % (k, v) for k, v in sorted(tot.items())), ndeg))


main()
