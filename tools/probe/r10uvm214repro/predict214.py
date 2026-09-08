#!/usr/bin/env python3
"""r10uvm214 — THE A-PRIORI PREDICTION, from OUR PRISTINE DATABASE ALONE.
MEASUREMENT ONLY; the official uhdm-cmp is the sole acceptance judge.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

THE FIRE SET is defined WITHOUT LOOKING AT GOLDEN, exactly as the patch's own
window is defined:

  a package-parameter REFERENCE whose holder chain is
      package[ALLPKG:P]<function|task:<C>::<m>…
  (the HOME package's DEF listing of an OUT-OF-BODY class method — a subroutine
  step whose name carries `::`; a free function has none), whose current
  `Actual_group` lives in the ELABORATED listing `package[TOPPKG:P]` of the SAME
  package P, and for which OUR OWN `package[ALLPKG:P]` listing holds a
  `param_assign` of that name.

  THE PREDICTED POST-PATCH PAYLOAD is that `param_assign`'s Rhs — read from our
  pristine database, so every cell's new value is named BEFORE the patched
  binary exists.

  THE `[package[TOPPKG:P]]` CLAUSE IS ALSO THE LAW'S `$unit` CONJUNCT.  Where a
  compilation-unit `import P::*;` hoists P's parameters into the DESIGN listing,
  golden binds the DESIGN-LEVEL PARAMETER OBJECT — and so do we already, through
  § unitImportHoistsPkgParams146's post-emission re-point — so such a cell's
  current payload reads `parameter@…[parameter[-:NAME]]`, not a TOPPKG object,
  and it does not fire.  A FIRST CUT of the law without that conjunct in the
  emitter moved exactly one such cell on `SimpleUVM` ×2 and `Scoreboard`/default
  and the census scored it AWAY-GOLDEN 1; this predicate never named those rows,
  which is how the over-fire was caught.

Only then is golden read, for the VERDICT of each fired cell:
  TO-GOLDEN   golden's row for the same (key, holder) carries the PREDICTED
              payload  — the cell lands on golden's own value;
  AWAY        golden carries the CURRENT payload — the patch would leave golden;
  MOVED-WRONG golden carries a THIRD payload — the cell moves but not onto
              golden;
  UNSEEN      golden has no row for that (key, holder) at all.

usage: predict214.py <golden.keycount> <ours.keycount> <ours.parhs>
"""
import re
import sys
from collections import Counter, defaultdict

HOLD = re.compile(r'^package\[ALLPKG:([^\]]+)\]<(?:function|task):([^<]*)')
LIST = re.compile(r'\[package\[TOPPKG:([^\]]+)\]\]')


def load_kc(path):
    rows = Counter()
    for line in open(path):
        if not line.startswith("KC\t"):
            continue
        p = line.rstrip("\n").split("\t")
        if len(p) != 5:
            continue
        rows[(p[1], p[2], p[3])] += int(p[4])
    return rows


def load_parhs(path):
    d = {}
    for line in open(path):
        if not line.startswith("PA\t"):
            continue
        p = line.rstrip("\n").split("\t")
        if len(p) != 4:
            continue
        d[(p[1], p[2])] = p[3]
    return d


def bare(n):
    return n.split("::")[-1]


def main():
    G = load_kc(sys.argv[1])
    O = load_kc(sys.argv[2])
    PA = load_parhs(sys.argv[3])
    # golden rows indexed by (key, holder) -> payload multiset
    gidx = defaultdict(Counter)
    for (k, pay, h), n in G.items():
        gidx[(k, h)][pay] += n

    fire = 0
    verd = Counter()
    for (key, pay, holder), n in sorted(O.items()):
        m = HOLD.match(holder)
        if not m:
            continue
        pkg, sub = m.group(1), m.group(2)
        if "::" not in sub:           # a free subroutine, not a clone listing
            continue
        lm = LIST.search(pay)
        if not lm or lm.group(1) != pkg:
            continue                  # not a cross-view binding into TOPPKG:P
        name = bare(key.split("|")[1])
        pred = PA.get(("package[ALLPKG:%s]" % pkg, name))
        if pred is None:
            verd["NO-DEF-RHS"] += n
            continue
        fire += n
        g = gidx.get((key, holder), Counter())
        if g.get(pred, 0) >= n:
            v = "TO-GOLDEN"
        elif g.get(pay, 0) >= n:
            v = "AWAY"
        elif sum(g.values()) == 0:
            v = "UNSEEN"
        else:
            v = "MOVED-WRONG"
        verd[v] += n
        print("FIRECELL\t%s\t%s\t%s\tCUR %s\tPRED %s" % (v, key, holder, pay,
                                                         pred))
    print("-- FIRE=%d TO-GOLDEN=%d AWAY=%d MOVED-WRONG=%d UNSEEN=%d NO-DEF-RHS=%d"
          % (fire, verd["TO-GOLDEN"], verd["AWAY"], verd["MOVED-WRONG"],
             verd["UNSEEN"], verd["NO-DEF-RHS"]))


if __name__ == "__main__":
    main()
