#!/usr/bin/env python3
"""r10earl29 GRID CELL EXTRACTOR — the NAME of every hier_path and the FULLNAME
of every bit_select, keyed by its SPAN, on BOTH sides, verbatim.

    usage: cells.py <g.dump> <o.dump> [<arm.sv>]

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours — the same order as
`uhdm-cmp <golden.uhdm> <ours.uhdm>`.  The column order never varies.

WHY THIS SHAPE:

  * SPAN-KEYED, not order-keyed.  `uhdm-dump` prints the same object many times
    (once per reference), so a positional pairing would compare an object with a
    re-print of a different one.  The key is (kind, line, col, endline, endcol),
    which is exactly what the campaign's span-keyed grep law asks for.

  * AN OBJECT IS NOT A DUMP OCCURRENCE.  Each key therefore collapses its
    occurrences to the SET of distinct name strings seen at that key; a key
    whose occurrences disagree would print more than one string and is visible
    rather than silently reduced to the first one.

  * A KEY PRESENT ON ONE SIDE ONLY prints `-NOOBJ-` for the other side and is
    counted as MISSING, never as a name difference: "we do not emit X" and "we
    name X differently" are different findings.

  * The optional third argument attaches the arm's SOURCE LINE to each cell, so
    the table reads as source -> golden name -> our name.
"""
import re
import sys
from collections import OrderedDict

# `\_hier_path: (name), line:29:11, endln:29:42`   (the dump's own spelling)
HDR = re.compile(
    r"^(?P<ind>\s*)\\?_?(?P<kind>hier_path|bit_select|part_select|var_select|indexed_part_select)"
    r": (?:(?P<nm>\S+) )?\((?P<name>.*)\), line:(?P<l>\d+):(?P<c>\d+), endln:(?P<el>\d+):(?P<ec>\d+)$"
)


def parse(path):
    cells = OrderedDict()
    with open(path, encoding="utf-8", errors="replace") as fh:
        for raw in fh:
            m = HDR.match(raw.rstrip("\n"))
            if not m:
                continue
            key = (m.group("kind"), int(m.group("l")), int(m.group("c")),
                   int(m.group("el")), int(m.group("ec")))
            cells.setdefault(key, [])
            if m.group("name") not in cells[key]:
                cells[key].append(m.group("name"))
    return cells


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    g = parse(sys.argv[1])   # LHS golden
    o = parse(sys.argv[2])   # RHS ours
    src = {}
    if len(sys.argv) > 3:
        with open(sys.argv[3], encoding="utf-8") as fh:
            for i, line in enumerate(fh, 1):
                src[i] = line.strip()
    keys = list(g.keys()) + [k for k in o if k not in g]
    keys.sort(key=lambda k: (k[1], k[2], k[0]))
    eq = df = miss = 0
    for k in keys:
        gv = " | ".join(g.get(k, [])) if k in g else "-NOOBJ-"
        ov = " | ".join(o.get(k, [])) if k in o else "-NOOBJ-"
        if k not in g or k not in o:
            verdict = "MISSING"
            miss += 1
        elif gv == ov:
            verdict = "EQ"
            eq += 1
        else:
            verdict = "DIFFER"
            df += 1
        print(f"{k[0]:<11} {k[1]}:{k[2]}-{k[3]}:{k[4]:<8} {verdict}")
        if src.get(k[1]):
            print(f"    SRC    {src[k[1]]}")
        print(f"    GOLDEN {gv}")
        print(f"    OURS   {ov}")
    print(f"CELLS={eq + df + miss} EQ={eq} DIFFER={df} MISSING(one side emits no object)={miss}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
