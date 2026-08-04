#!/usr/bin/env python3
"""Classify r10uvm7b rows-mode output: count (tag-prefix) per L-vs-R kind pair."""
import sys, re, collections
pat = sys.argv[2] if len(sys.argv) > 2 else None
c = collections.Counter()
tag = ""
lines = open(sys.argv[1]).read().split("\n")
i = 0
while i < len(lines):
    ln = lines[i]
    if ln.startswith("    L ") and i+1 < len(lines) and lines[i+1].startswith("    R "):
        lk = ln[6:].split(" ")[0]
        rk = lines[i+1][6:].split(" ")[0]
        key = lk + " vs " + rk
        if not pat or key == pat:
            # tag prefix: strip the trailing .Part/N
            t = re.sub(r'\.[A-Za-z_]+/\d+.*$', '', tag)
            t = re.sub(r'\[[^\]]*\]', '[]', t)
            c[key + "  ||  " + t] += 1
        i += 2
        continue
    if ln and not ln.startswith("    "):
        tag = ln
    i += 1
for k, n in c.most_common(40):
    print("%7d  %s" % (n, k))
