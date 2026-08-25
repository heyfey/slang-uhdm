#!/usr/bin/env python3
"""v136 verifier census: every class-property variable, keyed by its
fullname, valued by its UHDM class.  Read from uhdm-dump text, never a span,
never a file.  Multiset-safe: (fullname, kind) counted."""
import re, subprocess, sys, collections
DUMP = "/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump"
PAT = re.compile(r'\\_([a-z_0-9]*var|constant|ref_obj|array_var|packed_array_var):\s*\(([^)]*)\)')
def cells(path):
    out = subprocess.run([DUMP, path], capture_output=True, text=True).stdout
    c = collections.Counter()
    for m in PAT.finditer(out):
        kind, fn = m.group(1), m.group(2)
        if '::' not in fn: continue
        c[(fn, kind)] += 1
    return c
if __name__ == "__main__":
    for k, v in sorted(cells(sys.argv[1]).items()):
        print(f"{k[0]}\t{k[1]}\t{v}")
