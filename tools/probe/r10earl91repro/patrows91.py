#!/usr/bin/env python3
"""r10earl91 — the ARM SCORER for ct91pat rows.  MEASUREMENT ONLY.

Prints, per (parent-op SPAN, operand IDX, operand KIND, VpiSize), how many
copies each side holds.  A MULTISET join (RESUME §9: a last-writer dict drops
rows), never a dict keyed on the payload.

  usage: patrows91.py <gold.pat> <ours.pat> [<source.sv>] [--ops 75,76]
"""
import collections, re, sys

def load(p, ops):
    d = collections.Counter()
    for l in open(p):
        f = dict(x.split('=', 1) for x in l.strip().split('\t') if '=' in x)
        if f.get('POP') not in ops:
            continue
        d[(f['PSPAN'], f['IDX'], f['KIND'], f['SZ'])] += 1
    return d

def sk(k):
    m = re.match(r'(\d+):(\d+)', k[0])
    return (int(m.group(1)), int(m.group(2)), int(k[1]))

def main():
    a = [x for x in sys.argv[1:] if not x.startswith('--')]
    ops = {'75', '76'}
    for x in sys.argv[1:]:
        if x.startswith('--ops'):
            ops = set(x.split('=', 1)[1].split(','))
    g, o = load(a[0], ops), load(a[1], ops)
    src = open(a[2]).read().split('\n') if len(a) > 2 else None
    keys = sorted(set(g) | set(o), key=sk)
    print(f"{'PSPAN':22} {'IDX':3} {'KIND':12} {'SZ':>4} {'G':>2} {'O':>2}  src")
    diff = 0
    for k in keys:
        mark = '' if g[k] == o[k] else '   <<<'
        if g[k] != o[k]:
            diff += 1
        s = ''
        if src:
            ln = int(k[0].split(':')[0])
            s = src[ln - 1].strip()[:52] if ln <= len(src) else ''
        print(f"{k[0]:22} {k[1]:3} {k[2]:12} {k[3]:>4} {g[k]:>2} {o[k]:>2}  {s}{mark}")
    print(f"-- rows={len(keys)} differing={diff}")

main()
