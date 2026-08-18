#!/usr/bin/env python3
"""r10vrgg16/vcorpuscensus16.py — WHOLE-CORPUS interface_inst census.

usage: vcorpuscensus16.py <workdir-root> <label> <out.txt>

For every test workdir that has BOTH a golden database and our slang.uhdm, run
vcensus16 on both and report the differing keys.  The golden is found either in
the golden CACHE directory named by cmds.txt, or in the workdir's own
slpp_all/slpp_unit output.  A workdir where the golden cannot be located is
reported as NOGOLD and COUNTED (never silently skipped).
"""
import os, re, subprocess, sys, glob, collections

CEN = '/tmp/vrgg16_vcensus'
root, label, outp = sys.argv[1], sys.argv[2], sys.argv[3]

def golden_of(w):
    c = os.path.join(w, 'cmds.txt')
    if os.path.isfile(c):
        t = open(c).read()
        m = re.search(r'golden cache hit (\S+)\)', t)
        if m:
            g = os.path.join(m.group(1), 'golden.uhdm')
            if os.path.isfile(g):
                return g
    for sub in ('slpp_all', 'slpp_unit'):
        h = sorted(glob.glob(os.path.join(w, sub, '*.uhdm')))
        if h:
            return h[0]
    return None

def census(p):
    r = subprocess.run([CEN, p], capture_output=True, text=True)
    if r.returncode != 0:
        return None
    d = collections.defaultdict(collections.Counter)
    for ln in r.stdout.splitlines():
        parts = ln.split('\t')
        d[tuple(parts[:3])]['\t'.join(parts[3:])] += 1
    return d

tot = withif = diffdb = nogold = 0
diffkeys = 0
out = open(outp, 'w')
for mode in sorted(os.listdir(root)):
    md = os.path.join(root, mode)
    if not os.path.isdir(md):
        continue
    for t in sorted(os.listdir(md)):
        w = os.path.join(md, t)
        ours = os.path.join(w, 'slang.uhdm')
        if not os.path.isfile(ours):
            continue
        tot += 1
        g = golden_of(w)
        if not g:
            nogold += 1
            out.write(f'NOGOLD {mode}/{t}\n')
            continue
        cg, co = census(g), census(ours)
        if cg is None or co is None:
            out.write(f'CENSUS_FAIL {mode}/{t}\n')
            continue
        if not cg and not co:
            continue
        withif += 1
        ks = set(cg) | set(co)
        bad = [k for k in ks if cg.get(k) != co.get(k)]
        if bad:
            diffdb += 1
            diffkeys += len(bad)
            out.write(f'DIFF {mode}/{t} keys={len(bad)}/{len(ks)}\n')
            for k in sorted(bad):
                out.write(f'   KEY {k}\n')
                for lbl, c in (('GOLD', cg.get(k, {})), ('OURS', co.get(k, {}))):
                    for pl, n in sorted(c.items()):
                        out.write(f'      {lbl} x{n} {pl}\n')
out.write(f'== {label} databases={tot} with_interface_inst={withif} '
          f'DIFFERING_DBS={diffdb} DIFFERING_KEYS={diffkeys} NOGOLD={nogold}\n')
out.close()
print(open(outp).read().splitlines()[-1])
