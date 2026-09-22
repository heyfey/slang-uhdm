#!/usr/bin/env python3
"""r11u92 PER-NET-ENTRY ARBITER — LAW B is an ORDER and an ANCHOR, so the net
listing is scored TWICE: once per ENTRY (is this net in the holder's list, at
the span golden gives it?) and once per HOLDER (is the whole list in golden's
ORDER?).  A set-only score would call an order flip a match, which is exactly
the fault this pass closes.

Per entry, keyed (holder, name, occurrence-index-of-that-name):
  MATCH      same kind and same span as golden's entry in that slot
  DIFF       present in both, different span or kind (the ANCHOR fault)
  GOLD-ONLY  golden lists it and we do not
  OURS-ONLY  we list it and golden does not (a MINT)
Per holder:
  ORDER-OK / ORDER-DIFF over the NAME sequence (the ORDER fault), printed with
  both sequences so the reader never has to trust the verdict.

  usage: netcell93.py <gold.dump> <ours.dump> [--rows]
"""
import sys, os, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lister93 import listing


def entries(path):
    L = listing(path)
    out = {}
    order = {}
    for h, flds in L.items():
        seen = collections.Counter()
        seq = []
        for e in flds['vpiNet']:
            kind, name, span = e.split('|', 2)
            seen[name] += 1
            out[(h, name, seen[name])] = (kind, span)
            seq.append(name)
        order[h] = seq
    return out, order


def main():
    rows = '--rows' in sys.argv
    G, GO = entries(sys.argv[1])
    O, OO = entries(sys.argv[2])
    m = d = go = oo = 0
    for k in sorted(set(G) | set(O)):
        g, o = G.get(k), O.get(k)
        if g is None:
            oo += 1
            if rows:
                print('OURS-ONLY %s %s' % (k, o))
        elif o is None:
            go += 1
            if rows:
                print('GOLD-ONLY %s %s' % (k, g))
        elif g == o:
            m += 1
            if rows:
                print('MATCH     %s %s' % (k, g))
        else:
            d += 1
            if rows:
                print('DIFF      %s gold=%s ours=%s' % (k, g, o))
    ok = bad = 0
    for h in sorted(set(GO) | set(OO)):
        a, b = GO.get(h, []), OO.get(h, [])
        if a == b:
            ok += 1
        else:
            bad += 1
            if rows:
                print('ORDER-DIFF %-26s gold=%s ours=%s' % (h, a, b))
    print('NETS MATCH=%d DIFF=%d GOLD-ONLY=%d OURS-ONLY=%d | HOLDERS '
          'ORDER-OK=%d ORDER-DIFF=%d' % (m, d, go, oo, ok, bad))


if __name__ == '__main__':
    main()
