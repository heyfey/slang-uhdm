#!/usr/bin/env python3
"""r10rgg7/subtree7.py -- the OBJECT-KIND census of the `g_reduce`
gen_scope_array subtree at every elaborated rggen_or_reducer instance.

  usage: subtree7.py <dump> [<instance-path-substring> ...]

Prints one line per (instance, gen_scope_array): the subtree's object count and
its kind histogram, over CONTAINMENT edges only (vpiParent skipped).  With no
path filter every instance is printed, so an instance that VANISHED shows up as
a MISSING LINE and never as agreement.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dumptree as D
from collections import Counter

SKIP = {'|vpiParent:'}
dump = sys.argv[1]
filt = sys.argv[2:]
r = D.parse(dump)
d = [n for l, n in r.kids if n.kind == 'design'][0]
tot = 0
for view, lab in (('DEF', '|uhdmallModules:'), ('ELAB', '|uhdmtopModules:')):
    for t in [n for l, n in d.kids if l == lab]:
        for n in D.walk(t, SKIP):
            if n.kind != 'module_inst' or n.defname() != 'work@rggen_or_reducer':
                continue
            if filt and not any(f in n.name for f in filt):
                continue
            gsas = n.kids_of('|vpiGenScopeArray:', SKIP)
            tot += 1
            if not gsas:
                print('%s\t%s\tGSA=0' % (view, n.name))
            for g in gsas:
                nodes = list(D.walk(g, SKIP))
                print('%s\t%s\tGSA n=%d %s' %
                      (view, n.name, len(nodes),
                       dict(sorted(Counter(x.kind for x in nodes).items()))))
print('-- instances printed = %d' % tot)
if tot == 0:
    sys.exit(3)
