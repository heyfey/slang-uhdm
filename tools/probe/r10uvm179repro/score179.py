#!/usr/bin/env python3
"""r10uvm179 (r10uvm176's, reused) — the MULTISET JOIN and the two scoring columns.  MEASUREMENT ONLY.

  score179.py <golden.cen> <A.cen> [<B.cen>] [--drop=FIELD]

`--drop=RECV` removes every key field whose name is RECV before the join.  It
exists because a cell can be RIGHT IN VALUE and WRONG IN KEY: where our
receiver ref carries a different NAME from golden's (an unstripped subscript,
a trailing space), the cell is one-sided on the full key and scores
MOVED-WRONG even when its `vpiActual` moved straight to golden's.  Scoring
BOTH ways is the honest reading; neither alone is.

`--set` collapses each key's value MULTISET to a SET.  It is for the ELAB view
only, and for one measured reason: with `--elabuhdm` OUR database carries the
class DEFINITION's method AND its elaborated copy where Surelog's carries one,
so a cell reads `{BARE:1, BOUND:1}` against golden's `{BOUND:1}` before any
change and `{BOUND:2}` after — a MULTIPLICITY difference that predates this law
and swamps the bind reading.  The DEF view needs no such collapse and is
scored as a multiset.

Rows are `FAM|TAG|k1|k2|...|VALUE`.  The TAG column is dropped (it only says
which producer wrote the row) and the LAST field is the VALUE; everything
between is the KEY.  Keys COLLIDE (the same call argument shape appears in many
databases and, inside one database, in many specialisations), so both sides are
kept as MULTISETS: a dict keyed on the row would silently drop rows
(RESUME.md §9, census traps).

Columns, per family:
  AGREE          key present both sides with the same value multiset
  G-ONLY/O-ONLY  one-sided key multisets, printed in full when small
  DIFF           key present both sides, value multisets differ

With a THIRD file (the patched side) it additionally scores, per DIFF/one-sided
cell:
  TOGOLD       a cell that disagreed and now agrees
  AWAY         a cell that AGREED and now disagrees   (must be 0)
  MOVEDWRONG   a cell that disagreed, moved, and still disagrees (must be 0)
  STILLWRONG   a cell that disagreed and did not move
"""
import sys
from collections import Counter, defaultdict


def load(path, drop=None, asset=False):
    fams = defaultdict(lambda: defaultdict(Counter))
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            line = line.rstrip("\n")
            if not line:
                continue
            parts = line.split("|")
            if len(parts) < 3:
                continue
            fam = parts[0]
            fields = parts[2:-1]
            if drop:
                fields = [f for f in fields if not f.startswith(drop + "=")]
            key = "|".join(fields)
            val = parts[-1]
            fams[fam][key][val] += 1
    if asset:
        for fam in fams:
            for k in fams[fam]:
                fams[fam][k] = Counter({v: 1 for v in fams[fam][k]})
    return fams


def cmp_side(g, o):
    """returns (agree, gonly, oonly, diff) as lists of (key, gvals, ovals)"""
    agree, gonly, oonly, diff = [], [], [], []
    for k in set(g) | set(o):
        gv, ov = g.get(k), o.get(k)
        if gv is None:
            oonly.append((k, None, ov))
        elif ov is None:
            gonly.append((k, gv, None))
        elif gv == ov:
            agree.append((k, gv, ov))
        else:
            diff.append((k, gv, ov))
    return agree, gonly, oonly, diff


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    drop = None
    for a in sys.argv[1:]:
        if a.startswith("--drop="):
            drop = a.split("=", 1)[1]
    if len(args) < 2:
        print(__doc__)
        return 2
    asset = "--set" in sys.argv[1:]
    G = load(args[0], drop, asset)
    A = load(args[1], drop, asset)
    B = load(args[2], drop, asset) if len(args) > 2 else None

    fams = sorted(set(G) | set(A) | (set(B) if B else set()))
    for fam in fams:
        g, a = G.get(fam, {}), A.get(fam, {})
        ag, go, oo, df = cmp_side(g, a)
        print(f"== {fam} (A: pristine) AGREE={len(ag)} G-ONLY={len(go)} "
              f"O-ONLY={len(oo)} DIFF={len(df)}")
        for k, gv, ov in sorted(df)[:40]:
            print(f"   DIFF  {k}\n           G={dict(gv)}\n           O={dict(ov)}")
        for k, gv, _ in sorted(go)[:20]:
            print(f"   G-ONLY {k} = {dict(gv)}")
        for k, _, ov in sorted(oo)[:20]:
            print(f"   O-ONLY {k} = {dict(ov)}")
        if B is None:
            continue
        b = B.get(fam, {})
        bag, bgo, boo, bdf = cmp_side(g, b)
        print(f"== {fam} (B: patched)  AGREE={len(bag)} G-ONLY={len(bgo)} "
              f"O-ONLY={len(boo)} DIFF={len(bdf)}")
        wrongA = {k for k, _, _ in df} | {k for k, _, _ in go} | \
                 {k for k, _, _ in oo}
        wrongB = {k for k, _, _ in bdf} | {k for k, _, _ in bgo} | \
                 {k for k, _, _ in boo}
        togold = wrongA - wrongB
        away = wrongB - wrongA
        still = wrongA & wrongB
        movedwrong = set()
        for k in still:
            if a.get(k) != b.get(k):
                movedwrong.add(k)
        print(f"   TOGOLD={len(togold)} AWAY={len(away)} "
              f"MOVEDWRONG={len(movedwrong)} STILLWRONG={len(still - movedwrong)}")
        for k in sorted(togold)[:40]:
            print(f"   TOGOLD     {k}")
        for k in sorted(away)[:40]:
            print(f"   AWAY       {k}\n           G={dict(g.get(k, Counter()))}"
                  f"\n           A={dict(a.get(k, Counter()))}"
                  f"\n           B={dict(b.get(k, Counter()))}")
        for k in sorted(movedwrong)[:40]:
            print(f"   MOVEDWRONG {k}\n           G={dict(g.get(k, Counter()))}"
                  f"\n           A={dict(a.get(k, Counter()))}"
                  f"\n           B={dict(b.get(k, Counter()))}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
