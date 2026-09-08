#!/usr/bin/env python3
"""r10uvm213 — THE A-PRIORI PREDICTOR.  MEASUREMENT ONLY.

Run on the PRISTINE databases alone, before any patched sweep exists, it names
the cells § oobClassTypeParamPlaceholderPerView213 will move and what golden
says about each of them.

THE FIRE SET, read off OUR database only (this is what the code does):
  an **`unsupported_typespec`** copy whose HOLDER LISTING is
  `package[ALLPKG:P]<function|task:C::m` — the home package's DEF listing of an
  out-of-body class method — and whose `Instance` names `TOPPKG:P`, the
  ELABORATED twin of that same package.
Every such cell is re-stamped `ALLPKG:P` by the patch and NOTHING else moves.

THE KIND CONJUNCT IS LOAD-BEARING and was MEASURED, not assumed.  Without it
the predicate also catches the `class_typespec` copies a package DEF listing
holds for a class-handle local (`uvm_reg_field_cb_iter cbs`, `uvm_event_pool
ep`, ...) and the `enum_typespec` ones — and GOLDEN STAMPS THOSE
`TOPPKG:P` TOO (20 cells on SimpleUVM and on Scoreboard, 23 on BuildUVMPkg,
measured on the pristine pair).  They do not go through `oobDeclPkg31`, the
patch does not touch them, and a predicate that counted them would have
predicted 20-23 AWAY-GOLDEN cells that never move.

THE VERDICT, read off GOLDEN for each fired cell:
  TO-GOLDEN   golden says ALLPKG:P  -> the move lands on golden's own value
  AWAY        golden says TOPPKG:P  -> the move would leave golden (must be 0)
  UNSEEN      golden has no such cell at all (arity residue; reported, never
              counted as a win)

usage: predict213.py <golden.kc> <ours.kc> [--names]
"""
import re
import sys
from collections import Counter

HOLD = re.compile(r"^package\[ALLPKG:([A-Za-z_0-9@]+)\]<(?:function|task):[A-Za-z_0-9]+::")


def load(path):
    c = Counter()
    with open(path) as f:
        for line in f:
            if not line.startswith("KC\t"):
                continue
            _, key, view, holder, n = line.rstrip("\n").split("\t")
            c[(key, holder, view)] += int(n)
    return c


def main():
    names = "--names" in sys.argv
    G, O = load(sys.argv[1]), load(sys.argv[2])
    gcell = {}
    for (k, h, v), n in G.items():
        gcell.setdefault((k, h), Counter())[v] += n
    fire = tog = away = unseen = 0
    for (k, h, v), n in sorted(O.items()):
        if not k.startswith("unsupported_typespec|"):
            continue
        m = HOLD.match(h)
        if not m:
            continue
        p = m.group(1)
        if v != "TOPPKG:" + p:
            continue
        fire += n
        g = gcell.get((k, h))
        if g is None:
            unseen += n
            tag = "UNSEEN"
        elif g.get("ALLPKG:" + p, 0) >= n:
            tog += n
            tag = "TO-GOLDEN"
        elif g.get("TOPPKG:" + p, 0) >= n:
            away += n
            tag = "AWAY"
        else:
            unseen += n
            tag = "UNSEEN"
        if names:
            print("%s\t%d\t%s\t%s\tgolden=%s" % (tag, n, k, h, dict(g or {})))
    print("-- PREDICT FIRE=%d  TO-GOLDEN=%d  AWAY=%d  UNSEEN=%d" %
          (fire, tog, away, unseen))


if __name__ == "__main__":
    main()
