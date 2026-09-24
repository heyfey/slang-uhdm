#!/usr/bin/env python3
"""Authoritative campaign accounting, generated from the COMMITTED baselines.

Every test of both corpora is classified; the table must sum to the corpus
totals. This is the self-contained source of truth for status numbers —
prose in docs/commits is narrative; when they disagree, THIS wins.
Usage: python3 scripts/accounting.py [--md]
"""
import csv, collections, sys
md = '--md' in sys.argv
FILES = [('results/golden_surelog.csv', 'Surelog suite'),
         ('results/golden_uhdm2rtlil.csv', 'uhdm2rtlil')]
for f, label in FILES:
    for mode in ('default', 'testflags'):
        c = collections.Counter(r['status'] for r in csv.DictReader(open(f))
                                if r['mode'] == mode)
        tot = sum(c.values())
        # Since the strict flip (2026-09-24) CMP_EQUAL is strict-equal and
        # STRICT_NOTEQUAL is judge-equal only: both are judge-equal.
        judge = c['CMP_EQUAL'] + c['STRICT_NOTEQUAL']
        comp = judge + c['CMP_NOTEQUAL']
        jpct = 100 * judge / comp if comp else 0
        pct = 100 * c['CMP_EQUAL'] / comp if comp else 0
        body = ' '.join(f'{k}={v}' for k, v in
                        sorted(c.items(), key=lambda x: -x[1]))
        if md:
            print(f'| {label} | {mode} | {tot} | {body} | {comp} | '
                  f'{judge} ({jpct:.1f}%) | {c["CMP_EQUAL"]} ({pct:.1f}%) |')
        else:
            print(f'{label}/{mode}: total={tot} {body} | '
                  f'comparable={comp} judge-equal={jpct:.1f}% strict-equal={pct:.1f}%')
