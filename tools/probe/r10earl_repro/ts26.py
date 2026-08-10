#!/usr/bin/env python3
"""ts26.py <gdv.txt> <odv.txt> [scope-substr]

ONE LINE PER unpacked-dimension declaration, projecting the FOLDED BOUND
constant's two cmp-relevant answers side by side: its vpiSize and whether it
carries a ref_typespec.  GOLDEN first, OURS second, and a verdict column so the
three-way split of pass-26 residue (2) reads off the table instead of a diff.
"""
import re
import sys

ROW = re.compile(r"op\(11\)TS-\[const\{ct=\d+ sz=(\d+)[^}]*\}TS(\[[a-z_]+\]|-)")


def load(path, sub):
    out = {}
    for ln in open(path, errors="replace"):
        if sub and sub not in ln:
            continue
        f = ln.split()
        if len(f) < 4 or not f[2].startswith("array_"):
            continue
        m = ROW.search(ln)
        key = f[0] + " " + f[1]
        out[key] = (m.group(1), m.group(2)) if m else ("-", "-")
    return out


def main():
    g = load(sys.argv[1], sys.argv[3] if len(sys.argv) > 3 else "")
    o = load(sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else "")
    print("%-36s %-10s %-16s %-10s %-16s %s" %
          ("scope.decl", "G:size", "G:ts", "O:size", "O:ts", "verdict"))
    for k in g:
        if k not in o:
            continue
        gs, gt = g[k]
        os_, ot = o[k]
        v = []
        if gs != os_:
            v.append("SIZE %s->%s" % (os_, gs))
        if gt != ot:
            v.append("SUPPRESS" if gt == "-" else "ADD " + gt)
        sc, nm = k.split()
        print("%-36s %-10s %-16s %-10s %-16s %s" %
              (sc.split(".", 1)[-1] + "." + nm, gs, gt, os_, ot,
               "  ".join(v) if v else "equal"))


if __name__ == "__main__":
    main()
