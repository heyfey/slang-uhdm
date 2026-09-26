#!/usr/bin/env python3
"""summarize.py <grid.txt> [--md]: per law, its fresh cases with the strict verdict of the law-off state, the
landing-off (pristine) state and ON, and the grid.py classification of ON against the law's own switch; plus totals
per classification and the ALLOFF==PRE count.  Verdicts abbreviated: EQ = STRICT_EQUAL, S1 = NOT_EQUAL stage 1,
<field> = STRICT_NOTEQUAL on that first field, FAIL = no database."""
import sys, re, collections
lines = open(sys.argv[1]).read().splitlines(); md = '--md' in sys.argv
ver = {}   # (case, tag) -> verdict
res = collections.defaultdict(dict)  # case -> law -> (class, detail)
pre = collections.Counter()
def ab(s):
    if s.startswith('STRICT_EQUAL'): return 'EQ'
    if 'stage1' in s: return 'S1'
    if s.startswith('STRICT_NOTEQUAL_'): return s[len('STRICT_NOTEQUAL_'):]
    return s
for l in lines:
    m = re.match(r'\s+(\S+) (\S+) (?:cmp=\S+ cmplines=\S+ strict=(\S+)|(SURELOG_FAIL|SLANG_FAIL))', l)
    if m: ver[(m.group(1).replace('_el', '') if False else m.group(1), m.group(2))] = ab(m.group(3) or m.group(4)); continue
    if l.startswith('RESULT'):
        f = l.split(' ', 4); case, law = f[1], f[2]
        if law == 'ALLOFF==PRE': pre[f[3]] += 1; continue
        res[case][law] = (f[3] if len(f) > 3 else '?', f[4] if len(f) > 4 else '')
bylaw = collections.defaultdict(list); tally = collections.Counter()
for case, d in res.items():
    for law, (cl, det) in d.items():
        if law.startswith(('LANDING', 'PAIR', 'ALLOFF')): continue
        bylaw[law].append((case, cl)); tally[cl] += 1
for law in sorted(bylaw):
    cs = sorted(bylaw[law])
    c = collections.Counter(cl for _, cl in cs)
    print(f'### § {law}: {len(cs)} cases; ' + ', '.join(f'{k} {v}' for k, v in sorted(c.items())))
    if md: print('\n| case | law off | pristine (both landings off) | ON | ON vs law off |\n|---|---|---|---|---|')
    for case, cl in cs:
        tag = 'off_' + law
        row = (case, ver.get((case, tag), '?'), ver.get((case, 'alloff'), '?'), ver.get((case, 'on'), '?'), cl)
        print(('| ' + ' | '.join(row) + ' |') if md else '  ' + ' '.join(row))
    if md: print()
print('classification totals:', dict(sorted(tally.items())))
land = collections.Counter(v[0] for d in res.values() for k, v in d.items() if k.startswith('LANDING'))
allo = collections.Counter(v[0] for d in res.values() for k, v in d.items() if k == 'ALLOFF')
print('landing-off rows:', dict(sorted(land.items())), '| ALLOFF rows:', dict(sorted(allo.items())), '| ALLOFF170==PRE:', dict(pre))
tr = collections.Counter((ver.get((c, 'alloff'), '?') == 'EQ', ver.get((c, 'on'), '?') == 'EQ') for c in res)
print('cases STRICT_EQUAL: pristine', sum(1 for c in res if ver.get((c, 'alloff')) == 'EQ'), '-> ON', sum(1 for c in res if ver.get((c, 'on')) == 'EQ'),
      '| EQ lost (pristine EQ, ON not):', [c for c in res if ver.get((c, 'alloff')) == 'EQ' and ver.get((c, 'on')) != 'EQ'])
