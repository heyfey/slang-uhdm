#!/usr/bin/env python3
"""r10earl86 — the 3-WAY SCORER.  MEASUREMENT ONLY (uhdm-cmp is the judge).

Joins three pacen86 row files -- GOLDEN, PRISTINE, PATCHED -- as a MULTISET on
the census KEY (SPAN+VIEW+HOME+PNAME[+INST]; keys collide, so a last-writer
dict would silently DROP rows -- RESUME.md sec 9) and buckets every cell:

  SAME          pristine == patched == golden
  WRONG->RIGHT  pristine != golden, patched == golden        (the law working)
  RIGHT->WRONG  pristine == golden, patched != golden        (a REGRESSION)
  WRONG->OTHER  all three differ, pristine != patched         (MOVED-WRONG)
  STILL-WRONG   pristine == patched != golden                 (a residue)
  ONLY-GOLDEN / ONLY-OURS   unjoinable keys

Two payloads are scored side by side:
  JUDGE  the fields a generated Compare reads (spans STRIPPED) -- the bucket
         counts that matter, and the only ones any claim may rest on.
  FULL   the same rows WITH the per-node spans -- diagnosis only; a span flip
         is invisible to uhdm-cmp but visible in uhdm-dump.
Run pacen86 WITHOUT --spans for JUDGE and WITH it for FULL.

usage: score86.py <golden.rows> <pristine.rows> <patched.rows> [--label L]
"""
import sys, re
from collections import Counter

def load(p):
    rows = []
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln:
            continue
        k, _, v = ln.partition(' | ')
        rows.append((k, v))
    return rows

def strip_spans(v):
    # a TREE node group is d<n>:kind:op:sz:val:ct:dec:name:ts:sg[:span]
    def f(m):
        parts = m.group(0).split(':')
        # with --spans the trailing two fields are line:col-line:col
        if len(parts) >= 12:
            parts = parts[:10]
        return ':'.join(parts)
    return re.sub(r'd\d+:[^;]*', f, v)

def score(g, o, q, strip):
    def mk(rows):
        c = Counter()
        for k, v in rows:
            c[(k, strip_spans(v) if strip else v)] += 1
        return c
    # multiset join on the KEY first, then compare payload multisets per key
    def bykey(rows):
        d = {}
        for k, v in rows:
            d.setdefault(k, []).append(strip_spans(v) if strip else v)
        for k in d:
            d[k].sort()
        return d
    G, O, Q = bykey(g), bykey(o), bykey(q)
    b = Counter()
    detail = []
    for k in sorted(set(G) | set(O) | set(Q)):
        gv, ov, qv = G.get(k), O.get(k), Q.get(k)
        if gv is None:
            b['ONLY-OURS'] += max(len(ov or []), len(qv or []))
            continue
        if ov is None and qv is None:
            b['ONLY-GOLDEN'] += len(gv)
            continue
        n = max(len(gv), len(ov or []), len(qv or []))
        for i in range(n):
            a = gv[i] if i < len(gv) else None
            p = ov[i] if ov and i < len(ov) else None
            r = qv[i] if qv and i < len(qv) else None
            if p == a and r == a:
                b['SAME'] += 1
            elif p != a and r == a:
                b['WRONG->RIGHT'] += 1
                detail.append(('W2R', k))
            elif p == a and r != a:
                b['RIGHT->WRONG'] += 1
                detail.append(('R2W', k))
            elif p == r:
                b['STILL-WRONG'] += 1
                detail.append(('STILL', k))
            else:
                b['WRONG->OTHER'] += 1
                detail.append(('W2O', k))
    return b, detail

def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    label = ''
    for a in sys.argv[1:]:
        if a.startswith('--label'):
            label = a.split('=', 1)[-1]
    g, o, q = (load(a) for a in args[:3])
    for name, strip in (('JUDGE', True), ('FULL ', False)):
        b, d = score(g, o, q, strip)
        print(f"{label} {name} rows g={len(g)} o={len(o)} q={len(q)} :: " +
              ' '.join(f"{k}={b[k]}" for k in
                       ('SAME', 'WRONG->RIGHT', 'RIGHT->WRONG', 'WRONG->OTHER',
                        'STILL-WRONG', 'ONLY-GOLDEN', 'ONLY-OURS')))
        for tag, k in d:
            if tag in ('R2W', 'W2O', 'STILL'):
                print(f"   {name} {tag} {k}")

main()
