#!/usr/bin/env python3
# (r11u226: adapted from v11u219repro/drivers/sizevals.py to the grid's tags.)
# sizevals.py <grid case-view dir> [tag...]: for every cont_assign of golden and each tagged database (default: on,
# off_sizeReachFollowsWalker219v, off_ndaSizeFoldReach219, off_ndaAdjSizeFoldSized223, alloff), the left side's name
# and the right side's record (type : decompile : value : size), side by side; '<-- ON!=G' marks a cell ON misses and
# '(OFF==G)' when the switched-off state had golden's.  Each database is walked alone by uhdm-strictcmp --dump-a.
import sys, glob, os, subprocess, tempfile
SC = os.environ['STRICT_CMP']
def ca(u):
    f = tempfile.mktemp(prefix='r11u226_sv_')
    subprocess.run([SC, '--max', '0', '--dump-a', f, '--dump-b', '/dev/null', u, u], capture_output=True)
    out = {}; recs = [l.rstrip('\n').split('\t') for l in open(f, errors='replace') if l[:1].isdigit()]
    os.unlink(f)
    for i, r in enumerate(recs):
        if r[1] != 'cont_assign': continue
        d = int(r[0]); kids = []
        for s in recs[i + 1:]:
            if int(s[0]) <= d: break
            if int(s[0]) == d + 1: kids.append(s)
        if len(kids) >= 2:
            lhs = kids[1][2] or kids[1][4]; rhs = kids[0]
            out.setdefault(lhs, []).append(f'{rhs[1]}:{rhs[10]}:{rhs[12]}:{rhs[11]}')
    return out
d = sys.argv[1]; tags = sys.argv[2:] or ['on', 'off_sizeReachFollowsWalker219v', 'off_ndaSizeFoldReach219', 'off_ndaAdjSizeFoldSized223', 'alloff']
gg = glob.glob(d + '/gold_*/golden.uhdm')
if not gg: print('==', d, 'no golden'); sys.exit()
G = ca(gg[0]); T = {t: ca(f'{d}/{t}.uhdm') for t in tags if os.path.exists(f'{d}/{t}.uhdm')}
print('==', d.split('/r11u226_g/')[-1], 'tags:', ' '.join(T))
for k in sorted(set(G) | set().union(*[set(v) for v in T.values()])):
    if not k.startswith(('w', 't', 'iw', 'o')) or k.startswith('o'): continue
    g = sorted(G.get(k, []))
    row = [f'{k:4} G={g}']
    for t, v in T.items():
        x = sorted(v.get(k, []))
        row.append(f'{t}={"=G" if x == g else x}')
    print('  ' + ' | '.join(row))
