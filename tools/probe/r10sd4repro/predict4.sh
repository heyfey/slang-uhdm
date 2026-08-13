#!/usr/bin/env bash
# r10sd4 — CENSUS-PREDICT, run BEFORE the sweeps and from SOURCE ONLY.
#
# § classHomedTypeTsNoPkgInstance4 fires only where ALL of these hold:
#   (a) a QUEUE / DYNAMIC / ASSOCIATIVE array declaration exists,
#   (b) its ELEMENT TYPE is a typedef declared INSIDE a class, and
#   (c) the declaration is reached with a non-null `tsInst` — a package free
#       function or an OUT-OF-BODY class method (an in-body one has tsInst
#       null already, so the gate cannot change it).
#
# (c) cannot be seen from source without elaborating, so this predicate scores
# (a)+(b) and is stated as an UPPER BOUND, not a forecast.  It scans each test's
# own sources for a `typedef` that sits between `class`/`endclass` AND an
# unbounded/associative dimension anywhere in the same file.
#
# The four UVM designs are matched by NAME as well, because their shape lives in
# `third_party/UVM`, not in their own test directory — the same blind spot
# r10sd3's `predict.sh` had to add a second arm for.
set -u
python3 - "$@" <<'PY'
import os, re, sys
roots = [os.path.expanduser('~/git-repos/uhdm2rtlil/test'),
         os.path.expanduser('~/git-repos/Surelog/tests'),
         os.path.expanduser('~/git-repos/Surelog/third_party/tests')]
hit = []
for root in roots:
    if not os.path.isdir(root): continue
    for d in sorted(os.listdir(root)):
        p = os.path.join(root, d)
        if not os.path.isdir(p): continue
        cand = False; uvm = False
        for dp, _, fs in os.walk(p):
            for f in fs:
                if not f.endswith(('.sv', '.svh', '.v')): continue
                try: t = open(os.path.join(dp, f), errors='ignore').read()
                except OSError: continue
                if 'uvm_pkg' in t or 'uvm_macros' in t: uvm = True
                incls = False
                for ln in t.splitlines():
                    if re.search(r'\bclass\b', ln): incls = True
                    if re.search(r'\bendclass\b', ln): incls = False
                    if incls and re.search(r'\btypedef\b', ln):
                        if re.search(r'\[\s*\$\s*\]|\[\s*\]|\[\s*(string|int|logic)', t):
                            cand = True
        if cand or uvm: hit.append((root.split('/')[-1] + '/' + d, 'shape' if cand else 'uvm'))
print('CANDIDATE ROWS (upper bound):', len(hit))
for n, why in hit: print('  ', why, n)
PY
