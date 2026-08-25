#!/usr/bin/env python3
"""r10earl89 — the readable grid: one row per named array declaration, the
TYPESPEC answer on the folded left leg of the `[0 : E-1]` bound, GOLDEN first.
Payloads are deduped per key; no span is read.  MEASUREMENT ONLY.

  usage: grid89.py <armdir> [def|elab]
"""
import re, sys, collections, os

def load(p):
    d = collections.defaultdict(set)
    for ln in open(p):
        ln = ln.split(' || SPANS:')[0].strip()
        m = re.match(r'RG (.*)\|(\w+)\|(#\d+) (.*)$', ln)
        if m:
            d[(m.group(1), m.group(2))].add(m.group(4))
    return d

def leg(pays):
    out = set()
    for p in pays:
        m = re.search(r'R/op11\[0\]\{ct=(\d+) sz=(-?\d+) val=(\S+) dec=\S+ (TS=[^}]*)\}', p)
        if m:
            ts = m.group(4)[3:]
            out.add('ct%s/sz%-3s %s' % (m.group(1), m.group(2),
                                        'TS ' + ts if ts != 'none' else '-'))
    return ' ;; '.join(sorted(out)) or '(no folded leg)'

def main():
    d = sys.argv[1]
    v = '' if len(sys.argv) < 3 or sys.argv[2] == 'def' else 'e'
    G, O = load(os.path.join(d, 'g%s.rg' % v)), load(os.path.join(d, 'o%s.rg' % v))
    qp = os.path.join(d, 'q%s.rg' % v)
    Q = load(qp) if os.path.exists(qp) else None
    keys = [k for k in set(G) | set(O) if k[1] in ('array_var', 'array_net',
                                                   'array_typespec')]
    def nm(k):
        m = re.search(r'(array_var|array_net|array_typespec)\(([\w.\[\]]+)\)', k[0])
        return m.group(2) if m else '(anon)'
    def home(k):
        h = [x for x in k[0].split('/') if x.startswith(('module_inst(', 'gen_scope',
                                                         'interface_inst', 'package('))]
        return '.'.join(x.split('(')[-1].rstrip(')') for x in h[1:]) or 'top'
    print('%-26s %-10s %-34s %-34s %s' % ('cell', 'home', 'GOLDEN', 'pristine', 'patched'))
    for k in sorted(keys, key=lambda k: (nm(k), home(k))):
        g, o = leg(G.get(k, set())), leg(O.get(k, set()))
        q = leg(Q.get(k, set())) if Q else o
        flag = '' if g == q else ('   <== still differs' if g != o else '   <== MOVED AWAY')
        print('%-26s %-10s %-34s %-34s %s%s' % (nm(k), home(k), g, o, q, flag))

main()
