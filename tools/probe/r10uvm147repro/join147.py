#!/usr/bin/env python3
"""r10uvm147 — MEASUREMENT-ONLY multiset join of two ct147cen censuses.

LHS is ALWAYS golden.  Keys are (span|hier_path-name, ordinal-within-duplicates);
our hier_paths carry an EMPTY VpiFile, so the file component is DROPPED from the
key on both sides.  Payload compared: SIG (element shape signature), NELEM,
NSTEP, TRAILSEL.  Reports SHARED-EQUAL / DIFFER / GOLDEN-ONLY / OURS-ONLY.
   usage: join147.py <golden.cen> <ours.cen> [--show N] [--diffonly]
"""
import sys, collections

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln: continue
        f = ln.split('\t')
        key = f[0]
        # drop the file component (ours is empty)
        i = key.find(':')
        key = key[i+1:] if i >= 0 else key
        pay = {}
        for x in f[1:]:
            k, _, v = x.partition('=')
            pay[k] = v
        d[key].append(pay)
    return d

def main():
    g, o = load(sys.argv[1]), load(sys.argv[2])
    show = 0
    if '--show' in sys.argv: show = int(sys.argv[sys.argv.index('--show')+1])
    keys = sorted(set(g) | set(o))
    eq = diff = gonly = oonly = 0
    lines = []
    for k in keys:
        gl, ol = g.get(k, []), o.get(k, [])
        n = max(len(gl), len(ol))
        for i in range(n):
            gp = gl[i] if i < len(gl) else None
            op = ol[i] if i < len(ol) else None
            if gp is None:
                oonly += 1; lines.append(("OURS-ONLY", k, "-", op['SIG'])); continue
            if op is None:
                gonly += 1; lines.append(("GOLDEN-ONLY", k, gp['SIG'], "-")); continue
            same = all(gp.get(f) == op.get(f) for f in ('SIG','NELEM','NSTEP','TRAILSEL'))
            if same: eq += 1
            else:
                diff += 1; lines.append(("DIFFER", k, gp['SIG'], op['SIG']))
    if show:
        for t in lines[:show]:
            print(f"{t[0]}\t{t[1]}\n   G: {t[2]}\n   O: {t[3]}")
    print(f"CELLS shared-equal={eq} DIFFER={diff} GOLDEN-ONLY={gonly} OURS-ONLY={oonly} "
          f"wrong={diff+gonly+oonly}")

main()
