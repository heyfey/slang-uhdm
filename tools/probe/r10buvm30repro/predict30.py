#!/usr/bin/env python3
"""r10buvm30 — PREDICT the mover set BY NAME from the PRISTINE databases.

Consumes the two halves of runcen30.sh's output over a PRISTINE workdir:
  <prefix>.golden.tsv   golden's negative-decompile constants and minus ops
  <prefix>.ours.tsv     the SAME census over our PRISTINE databases

A database moves iff our pristine holds a vpiMinusOp in a PACKAGE section at a
(line, column) where golden holds a FOLDED negative constant at the SAME
(line, column) — the minus token's own span, which is exactly where the fold
lands.  Rows are joined as MULTISETS (a key can repeat: the same site appears
in both package views).

  predict30.py <prefix>            -> the predicted (test, mode) rows
  predict30.py <prefix> --sites    -> one line per predicted site
"""
import sys, collections

PKG = ('uhdmallPackages', 'uhdmtopPackages')

def load(path):
    neg, mop = collections.Counter(), collections.Counter()
    with open(path) as f:
        for line in f:
            p = line.rstrip('\n').split('\t')
            if len(p) < 5:
                continue
            kind, test, mode, sect, loc = p[0], p[1], p[2], p[3], p[4]
            if sect not in PKG or not loc:
                continue
            start = loc.split(',')[0]           # "L:C"
            key = (test, mode, start)
            if kind == 'NEG':
                neg[key] += 1
            elif kind == 'MOP':
                mop[key] += 1
    return neg, mop

def main():
    pre = sys.argv[1]
    gneg, _ = load(pre + '.golden.tsv')
    _, omop = load(pre + '.ours.tsv')
    sites = sorted(k for k in omop if k in gneg)
    rows = collections.Counter((t, m) for (t, m, _s) in sites)
    if '--sites' in sys.argv:
        for t, m, s in sites:
            print('SITE\t%s\t%s\t%s\tgolden_folded=%d ours_minusop=%d'
                  % (t, m, s, gneg[(t, m, s)], omop[(t, m, s)]))
    for (t, m), n in sorted(rows.items()):
        print('PREDICT-MOVER\t%s\t%s\tsites=%d' % (t, m, n))
    print('PREDICTED_DATABASES=%d  PREDICTED_SITES=%d' % (len(rows), len(sites)))
    # Upper bound: every package-section minus operation we hold, folded or not.
    ub = collections.Counter((t, m) for (t, m, _s) in omop)
    print('UPPER_BOUND_DATABASES=%d (every DB whose pristine holds ANY '
          'package-section vpiMinusOp)' % len(ub))

main()
