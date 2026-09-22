#!/usr/bin/env python3
"""r11u83 PER-CELL MOVED-WRONG SCORER — the arbiter.

r11v82's lesson: a per-BLOCK scan is blind below the block (a cell going the
wrong way inside an already-differing block cannot flip the block's verdict).
So this scores PER CELL, as a multiset join over three dumps per arm:

    gold   the pinned Surelog golden for that arm
    pris   the PRISTINE binary's database
    patch  the tag being scored

Two cell families, both keyed on COMPARED fields only (kind + name + the
declaration span, never `vpiFullName`):

  LIST  one row per `vpiVariables` / `vpiNet` / `vpiArrayNet` slot at ANY
        depth — the listing this pass's LAW A writes.
  CA    one row per `cont_assign`: its owner, its span, its Lhs name and its
        Rhs KIND and VALUE — the cell LAW B folds.

Per cell, `d = |gold - ours|`:
    CONVERTED   d_pris > 0 and d_patch == 0
    MOVED-WRONG d_pris == 0 and d_patch > 0
    AWAY        d_patch > d_pris  (and not already MOVED-WRONG)

`NOOWNER=1` drops the owner from the LIST key.  The owner is recovered from
dump INDENTATION, and a signal object nested inside another one (an
`array_net`'s inner element net) attributes to the nearest enclosing
instance, which differs between two dumps whose nesting differs — the one
artifact this scorer produced (i6_ifarray `v_sarr`, where golden and the
patched binary carry the SAME two objects and `uhdm-cmp` returns 0).  Running
both keyings is the cross-check.

usage: GRID=<dir> [NOOWNER=1] cellmw83.py <pris-tag> <patch-tag> [arms...]
"""
import os
import re
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
GRID = os.environ["GRID"]
SLOTS = ("vpiVariables", "vpiNet", "vpiNets", "vpiArrayNet", "vpiArrayNets")


def span(rest):
    m = re.search(r"line:(\d+:\d+), endln:(\d+:\d+)", rest)
    return "%s-%s" % (m.group(1), m.group(2)) if m else "-"


def name(rest):
    m = re.search(r"\(([^)]*)\)", rest)
    # the LAST dotted component only: the prefix is the view's, not a
    # compared field (`Compare` never reads VpiFullName).
    return m.group(1).split(".")[-1] if m else ""


def cells(fn):
    L = open(fn, errors="replace").read().splitlines()
    sect = "?"
    owners = []
    rows = []
    for i, l in enumerate(L):
        m = re.match(r"^\|(uhdm\w+|weaklyReferenced\w*):", l)
        if m:
            sect, owners = m.group(1), []
            continue
        mo = re.match(r"^(\s*)\\_(\w+):\s*(.*)$", l)
        if mo:
            ind, kind, rest = len(mo.group(1)), mo.group(2), mo.group(3)
            if kind in ("module_inst", "interface_inst", "gen_scope",
                        "package", "program"):
                while owners and owners[-1][0] >= ind:
                    owners.pop()
                owners.append((ind, name(rest) or kind))
            if kind == "cont_assign":
                own = "?"
                for (oi, on) in owners:
                    if oi < ind:
                        own = on
                lhs = rhsk = rhsv = "-"
                j = i + 1
                while j < len(L):
                    mj = re.match(r"^(\s*)\|vpi(Lhs|Rhs):\s*$", L[j])
                    if mj and len(mj.group(1)) == ind:
                        o = L[j + 1] if j + 1 < len(L) else ""
                        mk = re.match(r"^\s*\\_(\w+):\s*(.*)$", o)
                        if mk:
                            if mj.group(2) == "Lhs":
                                lhs = name(mk.group(2)) or mk.group(1)
                            else:
                                rhsk = mk.group(1)
                                rhsv = name(mk.group(2)) or span(mk.group(2))
                                k = j + 2
                                while k < len(L) and not re.match(
                                        r"^\s*\\_\w+:", L[k]):
                                    mv = re.match(
                                        r"^\s*\|((?:U?INT|BIN|HEX|DEC|OCT):"
                                        r"\S*)", L[k])
                                    if mv:
                                        rhsv += " " + mv.group(1)
                                        break
                                    k += 1
                    if re.match(r"^\s{0,%d}\\_\w+:" % max(ind - 1, 0), L[j]) \
                            and j > i:
                        break
                    j += 1
                rows.append(("CA", sect, own, span(rest), lhs, rhsk, rhsv))
            continue
        ms = re.match(r"^(\s*)\|(\w+):\s*$", l)
        if not ms or ms.group(2) not in SLOTS:
            continue
        ind = len(ms.group(1))
        o = L[i + 1] if i + 1 < len(L) else ""
        mo2 = re.match(r"^\s*\\_(\w+):\s*(.*)$", o)
        if not mo2:
            continue
        own = "?"
        for (oi, on) in owners:
            if oi < ind:
                own = on
        if os.environ.get("NOOWNER"):
            own = "-"
        rows.append(("LIST", sect, own, ms.group(2), mo2.group(1),
                     name(mo2.group(2)), span(mo2.group(2))))
    return Counter(rows)


def main():
    pris, patch = sys.argv[1], sys.argv[2]
    arms = sys.argv[3:] or sorted(
        d for d in os.listdir(GRID) if os.path.isdir(os.path.join(GRID, d)))
    tot = Counter()
    for a in arms:
        d = os.path.join(GRID, a)
        fg = os.path.join(d, "gold.%s.dump" % patch)
        fp = os.path.join(d, "ours.%s.dump" % pris)
        fx = os.path.join(d, "ours.%s.dump" % patch)
        if not all(os.path.exists(f) for f in (fg, fp, fx)):
            print("%-16s SKIP-NOFILE" % a)
            continue
        g, p, x = cells(fg), cells(fp), cells(fx)
        conv = wrong = away = 0
        for k in set(g) | set(p) | set(x):
            dp, dx = abs(g[k] - p[k]), abs(g[k] - x[k])
            if dp > 0 and dx == 0:
                conv += 1
            elif dp == 0 and dx > 0:
                wrong += 1
                print("MOVED-WRONG %-14s gold=%d pris=%d patch=%d  %s" %
                      (a, g[k], p[k], x[k], k))
            elif dx > dp:
                away += 1
                print("AWAY        %-14s gold=%d pris=%d patch=%d  %s" %
                      (a, g[k], p[k], x[k], k))
        print("%-16s cells=%d CONVERTED=%d MOVED-WRONG=%d AWAY=%d" %
              (a, len(set(g) | set(p) | set(x)), conv, wrong, away))
        tot["conv"] += conv
        tot["wrong"] += wrong
        tot["away"] += away
    print("TOTAL CONVERTED=%d MOVED-WRONG=%d AWAY-GOLDEN=%d" %
          (tot["conv"], tot["wrong"], tot["away"]))


main()
