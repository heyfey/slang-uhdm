#!/usr/bin/env python3
"""r10uvm117repro/score117.py — the ARM SCORER: golden vs pristine vs patched.

MEASUREMENT ONLY (the official uhdm-cmp is the judge).
LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

Reads three ct117cen listings and scores TWO cell families as MULTISETS
(a dict would drop a repeated key — RESUME §9):

  NET  the implicit wires, keyed (view, module fullname, name, span)
  REF  the reference bindings, keyed (view, owner, span, name) -> actual KIND

and prints, per family: cells where PATCHED agrees with golden and PRISTINE did
not (TO-GOLDEN), where PRISTINE agreed and PATCHED does not (AWAY-GOLDEN — must
be 0), and where neither agrees (STILL).

  usage: score117.py <g.txt> <pristine.txt> <patched.txt> [label]
"""
import sys, os, collections
MAXPRINT = int(os.environ.get('MAXPRINT', '200'))

def load(p):
    net, ref = collections.Counter(), {}
    dup = collections.Counter()
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 3: continue
        if f[1] == 'NET' and len(f) >= 9 and f[3] == 'IMPL':
            net[(f[2], f[4], f[6], f[5])] += 1
        elif f[1] == 'REF' and len(f) >= 14:
            k = (f[2], f[5], f[6], f[7])
            dup[k] += 1
            ref[k + (dup[k],)] = f[8]
    return net, ref

def main():
    g, o, q = (load(sys.argv[i]) for i in (1, 2, 3))
    label = sys.argv[4] if len(sys.argv) > 4 else ''
    # NET family, as a multiset difference.
    gn, on, qn = g[0], o[0], q[0]
    keys = set(gn) | set(on) | set(qn)
    tg = [k for k in keys if qn[k] == gn[k] and on[k] != gn[k]]
    aw = [k for k in keys if on[k] == gn[k] and qn[k] != gn[k]]
    st = [k for k in keys if qn[k] != gn[k] and on[k] != gn[k]]
    ok = [k for k in keys if qn[k] == gn[k] and on[k] == gn[k]]
    print('%s NET  agree_before=%d agree_after=%d  TO-GOLDEN=%d AWAY-GOLDEN=%d STILL=%d'
          % (label, len(ok) + len(aw), len(ok) + len(tg), len(tg), len(aw), len(st)))
    for tag, ks in (('TO-GOLDEN', tg), ('AWAY-GOLDEN', aw), ('STILL', st)):
        for k in sorted(ks)[:MAXPRINT]:
            print('  %-12s NET %s  g=%d pris=%d pat=%d' % (tag, '|'.join(k), gn[k], on[k], qn[k]))
        if len(ks) > MAXPRINT: print('  ... %d more %s NET rows' % (len(ks) - MAXPRINT, tag))
    # REF family.
    gr, orf, qr = g[1], o[1], q[1]
    keys = set(gr) | set(orf) | set(qr)
    gv = lambda d, k: d.get(k, 'ABSENT')
    tg = [k for k in keys if gv(qr, k) == gv(gr, k) and gv(orf, k) != gv(gr, k)]
    aw = [k for k in keys if gv(orf, k) == gv(gr, k) and gv(qr, k) != gv(gr, k)]
    st = [k for k in keys if gv(qr, k) != gv(gr, k) and gv(orf, k) != gv(gr, k)]
    ok = [k for k in keys if gv(qr, k) == gv(gr, k) and gv(orf, k) == gv(gr, k)]
    print('%s REF  cells=%d agree_before=%d agree_after=%d  TO-GOLDEN=%d AWAY-GOLDEN=%d STILL=%d'
          % (label, len(keys), len(ok) + len(aw), len(ok) + len(tg), len(tg), len(aw), len(st)))
    for tag, ks in (('TO-GOLDEN', tg), ('AWAY-GOLDEN', aw), ('STILL', st)):
        for k in sorted(ks)[:MAXPRINT]:
            print('  %-12s REF %s  g=%s pris=%s pat=%s'
                  % (tag, '|'.join(str(x) for x in k), gv(gr, k), gv(orf, k), gv(qr, k)))
        if len(ks) > MAXPRINT: print('  ... %d more %s REF rows' % (len(ks) - MAXPRINT, tag))

main()
