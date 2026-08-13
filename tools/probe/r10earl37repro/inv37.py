#!/usr/bin/env python3
# VERIFIER's INDEPENDENT design-scale invariant counter, run on a pactcen census.
#   (a) DEF-view port HighConn that is a ref_obj whose vpiName contains a '.'
#   (b) DEF-view port HighConn hier_path whose LAST vpiActual element is a
#       ref_obj rendered [NOFULL]
import re, sys
a = []; b = []
for ln in open(sys.argv[1], errors='replace'):
    if not ln.startswith('DEF'):
        continue
    parts = ln.rstrip('\n').split(' | ')
    head = parts[0]
    m = re.search(r"\s(\w+) name='([^']*)' @(\S+)", head)
    if not m:
        continue
    kind, name, span = m.groups()
    if kind == 'ref_obj' and '.' in name:
        a.append(ln.rstrip('\n'))
    if kind == 'hier_path':
        acts = [p for p in parts[1:] if p.startswith('vpiActual->')]
        if acts:
            last = acts[-1]
            if last.startswith('vpiActual->ref_obj(') and last.endswith('[NOFULL]'):
                b.append(ln.rstrip('\n'))
print("(a) DEF ref_obj HighConn with DOTTED name: %d" % len(a))
for x in a: print("   ", x[:150])
print("(b) DEF hier_path HighConn with NOFULL ref_obj leaf: %d" % len(b))
for x in b: print("   ", x[:150])
