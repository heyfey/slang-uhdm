#!/usr/bin/env python3
# instjoin.py <tsinst> <golden.uhdm> <ours.uhdm>: joins the two tsinst listings (multiset on listing, name, span,
# type) and prints every top-listed typespec whose Instance view differs, plus a count line:
#   TOPLIST agree=<n> golden_top_ours_def=<n> golden_def_ours_top=<n> other=<n> unmatched=<n>
import subprocess, sys, collections
def rows(t, db):
    out = subprocess.run([t, db], capture_output=True, text=True).stdout.splitlines()
    m = collections.defaultdict(list)
    for l in out:
        f = l.split()
        if len(f) < 5: continue
        key = (f[0], f[1], f[2], f[3])
        m[key].append(f[4].split(':')[0][5:])   # inst=<view>:<name> -> view
    return m
t, g, o = sys.argv[1:4]
G, O = rows(t, g), rows(t, o)
c = collections.Counter()
for k in sorted(set(G) | set(O)):
    if k[0] != 'toplist': continue
    gv, ov = sorted(G.get(k, [])), sorted(O.get(k, []))
    if len(gv) != len(ov): c['unmatched'] += 1; print('UNMATCHED', *k, gv, ov); continue
    for a, b in zip(gv, ov):
        if a == b: c['agree'] += 1
        elif a == 'top' and b == 'def': c['golden_top_ours_def'] += 1; print('GTOP_ODEF', *k)
        elif a == 'def' and b == 'top': c['golden_def_ours_top'] += 1; print('GDEF_OTOP', *k)
        else: c['other'] += 1; print('OTHER', *k, a, b)
print('TOPLIST ' + ' '.join(f'{x}={c[x]}' for x in ('agree', 'golden_top_ours_def', 'golden_def_ours_top', 'other', 'unmatched')))
