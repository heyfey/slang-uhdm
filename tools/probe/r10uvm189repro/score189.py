#!/usr/bin/env python3
# r10uvm189repro/score189.py — the arm / census scorer.  MEASUREMENT ONLY.
# LHS is ALWAYS golden; `a` is ALWAYS the PRISTINE side, `b` the PATCHED side.
#
# Reads three `ct189assoc cen` listings (golden, pristine, patched) and joins
# them on an ID-FREE, RANGE-SPAN-FREE key:
#
#     LISTING (last package frame + its DEF/ELAB view, plus a CDEFN marker) |
#     OWNER LINE:COL | OWNER NAME | DIM#
#
# The range's OWN span cannot enter the key: the two producers span a promoted
# range at the whole `[...]` bracket and a size range at the selector alone, so
# a span-keyed join would never bring the two forms it exists to compare into
# the same cell.
#
# TWO COLUMNS, scored separately and both reported, because the cell carries
# two independent axes and this pass's law governs only the first:
#
#   LAW      — `arrayType` (a COMPARED field of `array_var`) and the RIGHT
#              BOUND'S KIND (SENTINEL / SIZE / QUEUE / UNSIZED — the compared
#              `VpiType` of `range::Right_expr`, which is where the judge
#              stopped).
#   IDXTS    — the INDEX TYPESPEC's identity (kind + name + span).  A
#              pre-existing residue on this axis must not be laundered into
#              this law's column, and a regression on it must not be hidden by
#              the law's column; hence two columns rather than one verdict.
#
# Values are joined as a SET per key and both one-sided sets are printed:
# a form present on one side only is reported, never dropped.
import collections
import re
import sys


def parse(path):
    rows = []
    for line in open(path):
        line = line.rstrip("\n")
        if not line:
            continue
        path_part, rest = line.split(" | ", 1)
        frames = [f for f in path_part.split("<") if f]
        pkgs = [f for f in frames if f.startswith("package:")]
        cdefn = any(f.startswith("class_defn:") for f in frames)
        listing = (pkgs[0] if pkgs else "NOPKG") + ("|CDEFN" if cdefn else "")
        head, tail = rest.split(" || ", 1)
        kind, line_col, name, dim = [x.strip() for x in head.split(" | ")]
        payload = tail.split(" || sharers")[0].strip()
        at = re.search(r"arrayType=(-?\d+)", payload)
        idx = re.search(r"idxTs=(\S+)", payload)
        form = payload.split("|", 1)[1].strip() if "|" in payload else payload
        bound = form.split("(")[0].split(" ")[0].strip()
        if bound == "ASSOC":
            bound = "SENTINEL"
        law = "arrayType=%s bound=%s" % (at.group(1) if at else "?", bound)
        idxts = "idxTs=%s" % (idx.group(1) if idx else "NONE")
        if bound == "SENTINEL":
            m = re.search(r"idx=(\S+)", form)
            idxts += " inner=%s" % (m.group(1) if m else "NONE")
        rows.append(((listing, line_col, name, dim), law, idxts))
    return rows


def setmaps(rows):
    law = collections.defaultdict(set)
    its = collections.defaultdict(set)
    for k, l, i in rows:
        law[k].add(l)
        its[k].add(i)
    return law, its


def score(col, g, a, b, label, verbose):
    tog = away = mw = sw = unt = 0
    for k in sorted(set(g) | set(a) | set(b)):
        gv, av, bv = g.get(k), a.get(k), b.get(k)
        if gv is None or (av is None and bv is None):
            continue
        if av == gv and bv == gv:
            unt += 1
        elif av != gv and bv == gv:
            tog += 1
            if verbose:
                print("  %s TOGOLDEN   %s %s  %s -> %s" % (label, k[0], k[2], av, bv))
        elif av == gv and bv != gv:
            away += 1
            print("  %s AWAY       %s %s  %s -> %s  (golden %s)" % (label, k[0], k[2], av, bv, gv))
        elif av != bv:
            mw += 1
            print("  %s MOVEDWRONG %s %s  %s -> %s  (golden %s)" % (label, k[0], k[2], av, bv, gv))
        else:
            sw += 1
            if verbose:
                print("  %s STILLWRONG %s %s  ours %s  (golden %s)" % (label, k[0], k[2], av, gv))
    print("  %-5s TOGOLDEN=%d AWAY=%d MOVED-WRONG=%d STILL-WRONG=%d UNTOUCHED=%d"
          % (label, tog, away, mw, sw, unt))
    return tog, away, mw, sw, unt


def main():
    if len(sys.argv) < 4:
        print("usage: score189.py <cen.golden> <cen.pristine> <cen.patched> [-v]")
        return 2
    verbose = "-v" in sys.argv
    G, A, B = (parse(p) for p in sys.argv[1:4])
    gl, gi = setmaps(G)
    al, ai = setmaps(A)
    bl, bi = setmaps(B)
    keys = set(gl) | set(al) | set(bl)
    og = sorted(k for k in keys if k in gl and k not in al and k not in bl)
    oo = sorted(k for k in keys if k not in gl and (k in al or k in bl))
    oom = [k for k in oo if al.get(k) != bl.get(k)]
    print("KEYS=%d ONLY-GOLDEN=%d ONLY-OURS=%d ONLY-OURS-MOVED=%d"
          % (len(keys), len(og), len(oo), len(oom)))
    for k in og:
        print("  ONLY-GOLDEN %s" % (k,))
    for k in oo:
        print("  ONLY-OURS   %s  a=%s b=%s" % (k, al.get(k), bl.get(k)))
    score("law", gl, al, bl, "LAW", verbose)
    score("its", gi, ai, bi, "IDXTS", verbose)
    return 0


if __name__ == "__main__":
    sys.exit(main())
