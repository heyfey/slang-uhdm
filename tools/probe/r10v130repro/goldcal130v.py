#!/usr/bin/env python3
# r10v130repro/goldcal130v.py — GOLDEN-VS-GOLDEN CALIBRATION, run FIRST (RESUME §9).
# `default` and `testflags` are two INDEPENDENT Surelog runs of the same design.
# Every row of THIS FAMILY (an implicit module wire; a `new[...]`-argument
# reference and its actual) must agree between them, or no golden-vs-ours number
# below means anything.  Restricted to the tests the head family lives in — the
# UVM row-modes — because a design whose two modes ELABORATE DIFFERENTLY
# (Earlgrey's padring: -DSYNTHESIS et al) legitimately carries different nets and
# would drown the family's rows in unrelated ones.
# MEASUREMENT ONLY.  Both sides here are golden — that is the point.
import sys, os, subprocess, collections, re
W, CEN = sys.argv[1], sys.argv[2]
KEEP = ('SeqDriver', 'SimpleUVM', 'Scoreboard', 'MiniAmiq', 'BuildUVMPkg')
def gold(cmds):
    t = open(cmds, encoding='utf-8', errors='replace').read()
    m = re.search(r'(/\S*golden\.uhdm)', t)
    if m: return m.group(1)
    m = re.search(r'(/\S*slang-uhdm-goldens/[0-9a-f]+)', t)
    return m.group(1).rstrip(')') + '/golden.uhdm' if m else None
def fam(db):
    r = subprocess.run([CEN, db, 'G'], capture_output=True, text=True)
    if r.returncode: return None
    rows = collections.Counter()
    for ln in r.stdout.splitlines():
        f = ln.split('\t')
        if len(f) < 3: continue
        if f[1] == 'NET' and f[3] == 'IMPL':
            rows[('NET', f[4], f[5], f[6])] += 1
        elif f[1] == 'REF' and len(f) >= 15 and f[14] == 'NEWARG':
            rows[('REF', f[6], f[7], f[8], f[9], f[12])] += 1
    return rows
byname = collections.defaultdict(dict)
for mode in ('default', 'testflags'):
    md = os.path.join(W, mode)
    if not os.path.isdir(md): continue
    for d in os.listdir(md):
        if not any(d.startswith(k + '-') for k in KEEP): continue
        c = os.path.join(md, d, 'cmds.txt')
        if os.path.isfile(c):
            g = gold(c)
            if g and os.path.isfile(g): byname[d][mode] = g
pairs = diffs = rows = skip = 0
for name, mm in sorted(byname.items()):
    if len(mm) < 2: skip += 1; continue
    a, b = fam(mm['default']), fam(mm['testflags'])
    if a is None or b is None: skip += 1; continue
    pairs += 1; rows += sum(a.values())
    if a != b:
        diffs += 1
        print("PAIR-DIFFERS", name, (a - b) or '', (b - a) or '')
    else:
        print(f"PAIR-AGREES  {name}  rows={sum(a.values())}")
print(f"pairs={pairs} rows={rows} PAIRS_DIFFER={diffs} SKIP={skip}  EXPM_N={diffs}")
