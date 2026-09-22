#!/usr/bin/env python3
"""r11u84 ORDERED lister - pkgscore79's own parse, printed in DUMP ORDER per
package and per vector, so the SLOT question and the MULTISET question are
both answerable.  usage: ordlist.py gold.dump ours.dump SECT [pkg...]"""
import sys
import os
SRC = os.path.join(os.path.dirname(os.path.abspath(__file__)), "pkgscore79.py")
src = open(SRC).read().split("def main()")[0]
ns = {}; exec(src, ns); parse, face = ns["parse"], ns["face"]
g, o = parse(sys.argv[1]), parse(sys.argv[2]); sect = sys.argv[3]
want = set(sys.argv[4:])
def per(rows):
    d = {}
    for r in rows:
        if r[0] != sect: continue
        nm = r[4].strip("()")
        pkg = nm.split("::")[0]
        f = face(r)
        tag = f.split()[0].split("/")[1]
        if "nett=" in f: tag += "/nt" + f.split("nett=")[1].split()[0]
        if "size=" in f: tag += "/sz" + f.split("size=")[1].split()[0]
        d.setdefault(pkg, []).append(nm.split("::")[-1] + ":" + tag)
    return d
A, B = per(g), per(o)
for p in sorted(set(A) | set(B)):
    if want and p not in want: continue
    ga, ob = A.get(p, []), B.get(p, [])
    print(("EQ " if ga == ob else "NE ") + "PKG " + p)
    print("    GOLD", ga)
    print("    OURS", ob)
