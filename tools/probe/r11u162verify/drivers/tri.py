#!/usr/bin/env python3
"""tri.py <gw case dir> <off tag> [on tag]: the dump lines that differ between OFF and ON (order-blind,
path-normalised), each marked by whether golden holds it: `-` only in OFF, `+` only in ON, then
[G] when golden has that line (multiset), [ ] when not.  A `+ [ ]` line with no `- [ ]` partner is a new wrong line."""
import os, re, subprocess, sys, collections, glob
D = os.environ['UHDM_DUMP']
w, off = sys.argv[1], sys.argv[2]; on = sys.argv[3] if len(sys.argv) > 3 else 'on'
def dump(f):
    t = subprocess.run([D, f], capture_output=True, text=True, errors='replace').stdout
    return collections.Counter(re.sub(r'id:\d+', '', re.sub(r'/[^ ,:()]*/', '', l)).strip() for l in t.splitlines() if 'Restored design' not in l)
g = dump(glob.glob(f'{w}/gold_*/golden.uhdm')[0]); a = dump(f'{w}/{off}.uhdm'); b = dump(f'{w}/{on}.uhdm')
for l, n in sorted((a - b).items()): print(f'- [{"G" if g[l] else " "}] x{n} {l}')
for l, n in sorted((b - a).items()): print(f'+ [{"G" if g[l] else " "}] x{n} {l}')
