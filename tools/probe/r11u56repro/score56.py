#!/usr/bin/env python3
"""r11u56 CELL SCORER — join the ELAB cont_assign cells of two dumps by the
Lhs NAME (instance-qualified), print SAME/DIFF per cell and a tally.

usage: score56.py <golden.dump> <ours.dump> [label]
A cell key is the Lhs ref_obj's full name; a dump that yields ZERO cells exits
4 through caread55.py, so a reader that reaches nothing cannot read as
agreement."""
import re
import subprocess
import sys
import os

CAREAD = os.environ.get(
    "CAREAD", "/tmp/wt_r11u56/tools/probe/r11u55repro/caread55.py")


def cells(dump):
    out = subprocess.run([sys.executable, CAREAD, dump, "ELAB"],
                         capture_output=True, text=True)
    if out.returncode != 0:
        print("READER FAILED on %s: %s" % (dump, out.stdout.strip()))
        sys.exit(4)
    d = {}
    for l in out.stdout.splitlines():
        m = re.search(r'LHS=ref_obj\(\(([^)]+)\)\)', l)
        v = re.search(r'RHS=(\S+)\s+@(\S+)\s+(.*)$', l)
        if not m:
            continue
        d[m.group(1)] = (v.group(1), v.group(2), v.group(3).strip()) if v else ("?", "?", l)
    return d


def main():
    g, o = cells(sys.argv[1]), cells(sys.argv[2])
    tag = sys.argv[3] if len(sys.argv) > 3 else ""
    same = diff = 0
    for k in sorted(set(g) | set(o)):
        a, b = g.get(k), o.get(k)
        if a == b:
            same += 1
            print("SAME %-28s %s" % (k, a))
        else:
            diff += 1
            print("DIFF %-28s\n   G %s\n   O %s" % (k, a, b))
    print("%s CELLS %d SAME %d DIFF %d" % (tag, same + diff, same, diff))


if __name__ == "__main__":
    main()
