#!/usr/bin/env python3
# order-blind uhdm-dump distance: obd.py golden.uhdm ours.uhdm -> multiset symmetric diff of id-stripped, path-stripped dump lines
import sys, subprocess, re, collections, os
D = os.environ['UHDM_DUMP']
def lines(f):
    t = subprocess.run([D, f], capture_output=True, text=True).stdout
    out = []
    for l in t.splitlines():
        l = re.sub(r', id:\d+', '', l); l = re.sub(r'file:\S*/', 'file:', l); l = re.sub(r'id:\d+', '', l)
        out.append(l.strip())
    return collections.Counter(out)
a, b = lines(sys.argv[1]), lines(sys.argv[2])
print(sum(((a - b) + (b - a)).values()))
