#!/usr/bin/env python3
# r10v144 (VERIFIER) — the A-PRIORI mover predictor for the two verifier fixes,
# read off a PRISTINE `uhdm-dump` before any patched sweep.
#   FIX 2 candidate: a `named_begin` that OWNS |vpiVariables: and sits under a
#     function/task whose vpiFullName carries a class scope -- i.e. exactly the
#     cell § namedBlkLocalNeverBindsInBodyWindow144v can silence.
#   FIX 1 candidate: a class-owned `function` named `new` whose FIRST listed
#     variable shares a line:col RANGE START with a second listed variable, the
#     database's only visible trace of `int a, b;` in one declaration.
# Deliberate OVER-approximations: the measured byte-mover set must be a SUBSET.
#   usage: pred144v.py <dump>
import sys, re

def ind(s): return len(s) - len(s.lstrip(' '))

lines = open(sys.argv[1], errors='replace').read().split('\n')
n = len(lines)
nb = 0
ctor = 0
for i, l in enumerate(lines):
    m = re.match(r'(\s*)\\_named_begin: ', l)
    if m:
        base = ind(l)
        j = i + 1
        while j < n and lines[j].strip() and ind(lines[j]) > base:
            if ind(lines[j]) == base + 2 and lines[j].strip() == '|vpiVariables:':
                nb += 1
                break
            j += 1
        continue
    m = re.match(r'(\s*)\\_function: \(([^)]*)\)', l)
    if m and m.group(2).endswith('::new'):
        base = ind(l)
        seen = {}
        j = i + 1
        while j < n and lines[j].strip() and ind(lines[j]) > base:
            if ind(lines[j]) == base + 2 and lines[j].strip() == '|vpiVariables:':
                mm = re.search(r'line:(\d+):(\d+)', lines[j + 1] or '')
                if mm:
                    seen[mm.group(1)] = seen.get(mm.group(1), 0) + 1
            j += 1
        if any(v > 1 for v in seen.values()):
            ctor += 1
print('NAMEDBLK_WITH_VARS\t%d\tCTOR_SAMELINE_MULTIVAR\t%d' % (nb, ctor))
