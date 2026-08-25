#!/usr/bin/env python3
# r10v130repro/score130v.py — VERIFIER scorer.  MEASUREMENT ONLY; the official
# uhdm-cmp is the judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
# Reads three ct130cen censuses (golden / pristine / patched) and scores every
# NET and REF cell three ways: TO-GOLDEN, AWAY-GOLDEN, SAME.
import sys, collections

def load(p):
    nets, refs = {}, {}
    for ln in open(p, encoding='utf-8', errors='replace'):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 3: continue
        if f[1] == 'NET':
            # tag NET view IMPL module span name kind nettype
            key = (f[2], f[4], f[6])
            nets.setdefault(key, []).append((f[3], f[5], f[7], f[8]))
        elif f[1] == 'REF':
            # tag REF view oob home owner span name actkind actnm par parnm actimpl newlhs ctx topk
            key = (f[2], f[6], f[7])
            refs.setdefault(key, []).append((f[8], f[9], f[12], f[14]))
    for d in (nets, refs):
        for k in d: d[k] = tuple(sorted(d[k]))
    return nets, refs

def score(g, a, b, kind, out):
    to = away = same = onlyg = onlyo = 0
    keys = set(g) | set(a) | set(b)
    for k in sorted(keys):
        gv, av, bv = g.get(k), a.get(k), b.get(k)
        if av == bv:
            if gv != av: same += 1
            continue
        # pristine and patched differ on this cell
        if bv == gv and av != gv:
            to += 1; out.append(f"TO-GOLDEN   {kind} {k} g={gv} pris={av} pat={bv}")
        elif av == gv and bv != gv:
            away += 1; out.append(f"AWAY-GOLDEN {kind} {k} g={gv} pris={av} pat={bv}")
        else:
            out.append(f"MOVED-NEITHER {kind} {k} g={gv} pris={av} pat={bv}")
    return to, away

def main():
    gf, af, bf = sys.argv[1:4]
    gn, gr = load(gf); an, ar = load(af); bn, br = load(bf)
    out = []
    tn, an_ = score(gn, an, bn, 'NET', out)
    tr, ar_ = score(gr, ar, br, 'REF', out)
    for l in out: print(l)
    print(f"SCORE NET to-golden={tn} away={an_}   REF to-golden={tr} away={ar_}")
main()
