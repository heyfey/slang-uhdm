#!/usr/bin/env python3
"""lawtable.py <grid result dir> <grid state lines>: the per-law table of the fresh grid.  From drivers/grid.py's
RESULT lines (one per case-view and law / landing / pair) and its per-state lines (`rel tag cmp=.. strict=.. rc=..`):
per law the case-views scored, the verdict tally (UNFIRED TOWARD BYTES-ONLY AWAY MIXED UNMASK STAGE1-CLOSER/SAME/AWAY),
and the case-views entering EQUAL (the law's off state not STRICT_EQUAL, on STRICT_EQUAL) and leaving it."""
import sys, re, glob, collections
R, S = sys.argv[1:3]
state = collections.defaultdict(dict)
for l in open(S):
    p = l.split()
    if len(p) < 3: continue
    m = re.search(r'strict=(\S+)', l)
    state[p[0]][p[1]] = m.group(1) if m else p[2]
tab = collections.defaultdict(collections.Counter); conv = collections.defaultdict(list); leave = collections.defaultdict(list)
for f in sorted(glob.glob(R + '/*.txt')):
    for l in open(f):
        if not l.startswith('RESULT ') or l.startswith('RESULT CRASH'): continue
        p = l.split()
        if len(p) < 4: continue
        cv, law, v = p[1], p[2], p[3]
        tab[law][v] += 1
        tag = {'ALLOFF': 'alloff', 'WIDE': 'wide'}.get(law) or ('offL' + law[7:] if law.startswith('LANDING') else None)
        if tag is None and not law.startswith(('PAIR:', 'EXTRA:')):
            tag = 'off_' + law.replace(':', '_')
        if tag and tag in state[cv]:
            on, off = state[cv].get('on', ''), state[cv][tag]
            if on.startswith('STRICT_EQUAL') and not off.startswith('STRICT_EQUAL'): conv[law].append(cv)
            if off.startswith('STRICT_EQUAL') and not on.startswith('STRICT_EQUAL'): leave[law].append(cv)
V = ['UNFIRED', 'TOWARD', 'BYTES-ONLY', 'UNMASK', 'AWAY', 'MIXED', 'STAGE1-CLOSER', 'STAGE1-SAME', 'STAGE1-AWAY', 'DB-PRESENCE-DIFFERS', 'NODB']
print('| law or state | case-views | ' + ' | '.join(V) + ' | enter STRICT_EQUAL | leave STRICT_EQUAL |')
print('|' + '---|' * (len(V) + 4))
for law in sorted(tab, key=lambda x: (x.startswith(('LANDING', 'ALLOFF', 'WIDE', 'PAIR')), x)):
    c = tab[law]
    print(f'| {law} | {sum(c.values())} | ' + ' | '.join(str(c.get(v, 0)) for v in V) + f' | {len(conv[law])} | {len(leave[law])}' + (' (' + ' '.join(leave[law]) + ')' if leave[law] else '') + ' |')
