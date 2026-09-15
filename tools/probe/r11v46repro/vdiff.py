#!/usr/bin/env python3
# v11u46 verifier: order-blind, id-blind, path-blind WHOLE-DUMP distance,
# SECTIONED into DEF (before |uhdmtopModules:) / ELAB (after) / TAIL
# (weaklyReferenced, unreachable to the judge -> reported but not scored).
# Usage: vdiff.py golden.raw ours.raw [--show N]
import re, sys, collections

def norm(path):
    secs = {'DEF': [], 'ELAB': [], 'TAIL': []}
    view = 'DEF'
    for ln in open(path, errors='replace'):
        if '|uhdmtopModules:' in ln:
            view = 'ELAB'
        if '|uhdmweaklyReferenced' in ln or '|weaklyReferenced' in ln:
            view = 'TAIL'
        t = ln.rstrip('\n')
        t = re.sub(r', id:\d+', '', t)
        t = re.sub(r'\bid:\d+', '', t)
        t = re.sub(r'/[^ ,)]*/(slpp_all|[A-Za-z0-9_]+\.sv)', r'\1', t)
        t = re.sub(r'file:[^,]*', 'file:', t)
        secs[view].append(t)
    return {k: collections.Counter(v) for k, v in secs.items()}

g = norm(sys.argv[1]); o = norm(sys.argv[2])
show = 0
if '--show' in sys.argv:
    show = int(sys.argv[sys.argv.index('--show') + 1])
tot = 0
for v in ('DEF', 'ELAB', 'TAIL'):
    gm = g[v] - o[v]; om = o[v] - g[v]
    n = sum(gm.values()) + sum(om.values())
    if v != 'TAIL':
        tot += n
    print("%-5s DIST %d   (golden-only %d / ours-only %d)" %
          (v, n, sum(gm.values()), sum(om.values())))
    if show:
        for k, c in list(gm.items())[:show]:
            print("   G%-3d %s" % (c, k.strip()))
        for k, c in list(om.items())[:show]:
            print("   O%-3d %s" % (c, k.strip()))
print("NETDIST %d  (DEF+ELAB, TAIL excluded)" % tot)
