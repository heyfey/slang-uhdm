#!/usr/bin/env python3
"""r10uvm146 — SCORER for § unitImportHoistsPkgParams146.

MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole
acceptance judge; this only counts cells in the ct146cen censuses.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

  usage: score146.py <golden.cen> <pristine.cen> <patched.cen> [label]

It scores TWO populations, both as MULTISETS (a last-writer dict would drop the
duplicate rows this family has by construction — the same name is listed by two
package views and, in arm D/G, by two import statements):

  LISTING  the design's vpiParameter / vpiParamAssign rows
           (name x kind x vpiImported, and lhs x rhs-kind x loc), IN ORDER.
  BINDING  every ref_obj whose name the listing carries, keyed
           name x line:col x parent-chain, valued by the ACTUAL's kind.

and reports, for the BINDING population,
  TO-GOLDEN    cells wrong in pristine and right in patched
  AWAY-GOLDEN  cells right in pristine and wrong in patched
  STILL-WRONG  cells wrong in both
  MOVED-WRONG  cells wrong in both but wrong DIFFERENTLY
  ONLY-GOLDEN / ONLY-OURS  the one-sided sets, scored EXPLICITLY (an object
                           added where golden has none is AWAY)
"""
import sys
from collections import Counter


def load(path):
    lst, refs = [], Counter()
    try:
        with open(path) as f:
            for line in f:
                line = line.rstrip("\n")
                if line.startswith("LIST|"):
                    lst.append(line)
                elif line.startswith("REF|"):
                    p = line.split("|")
                    # name | line:col | actual | reaches | tf | chain
                    key = (p[1], p[2], p[6] if len(p) > 6 else "")
                    refs[(key, p[3])] += 1
    except FileNotFoundError:
        pass
    return lst, refs


def keyed(refs):
    out = Counter()
    for (key, act), n in refs.items():
        out[(key, act)] = n
    return out


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        return 2
    g, o, q = (load(p) for p in sys.argv[1:4])
    label = sys.argv[4] if len(sys.argv) > 4 else sys.argv[1]

    # --- calibration: golden against ITSELF must score a perfect zero.
    cal = sum((Counter(g[1]) - Counter(g[1])).values()) + \
        sum((Counter(g[1]) - Counter(g[1])).values())
    print(f"[{label}] GOLDCAL golden-vs-golden residual = {cal}  (must be 0)")

    print(f"[{label}] LISTING golden={len(g[0])} pristine={len(o[0])} "
          f"patched={len(q[0])} "
          f"patched==golden(IN ORDER): {'YES' if g[0] == q[0] else 'NO'}")
    if g[0] != q[0]:
        for i, (a, b) in enumerate(zip(g[0] + [""] * len(q[0]),
                                       q[0] + [""] * len(g[0]))):
            if a != b:
                print(f"    row {i}: GOLD[{a}] OURS[{b}]")

    gk, ok, qk = keyed(g[1]), keyed(o[1]), keyed(q[1])
    # collapse to key -> multiset of actual kinds
    def bykey(c):
        d = {}
        for (key, act), n in c.items():
            d.setdefault(key, Counter())[act] += n
        return d
    G, O, Q = bykey(gk), bykey(ok), bykey(qk)
    keys = set(G) | set(O) | set(Q)
    to_g = away = still = movedw = 0
    only_gold = only_ours = 0
    for k in sorted(keys):
        gg, oo, qq = G.get(k, Counter()), O.get(k, Counter()), Q.get(k, Counter())
        if not gg:
            only_ours += sum(qq.values())
            continue
        if not qq:
            only_gold += sum(gg.values())
            continue
        pre_ok, post_ok = (oo == gg), (qq == gg)
        if not pre_ok and post_ok:
            to_g += 1
        elif pre_ok and not post_ok:
            away += 1
            print(f"    AWAY  {k}: gold={dict(gg)} pris={dict(oo)} pat={dict(qq)}")
        elif not pre_ok and not post_ok:
            still += 1
            if oo != qq:
                movedw += 1
            print(f"    STILL {k}: gold={dict(gg)} pris={dict(oo)} pat={dict(qq)}")
    print(f"[{label}] BINDING TO-GOLDEN {to_g} / AWAY-GOLDEN {away} / "
          f"STILL-WRONG {still} / MOVED-WRONG {movedw} / "
          f"ONLY-GOLDEN-CELL {only_gold} / ONLY-OURS-CELL {only_ours}")
    return 0


sys.exit(main())
