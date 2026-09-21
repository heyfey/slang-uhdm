#!/usr/bin/env python3
"""r11u71 SITE CENSUS JOIN — the gate-profile table and the A-PRIORI MOVER SET.

Reads `cellcen71.py`'s tsv (one row per generate-scope cont_assign that reaches
§ caStructParamGenScopeShareCut71's site, the DECLINED ones included) and prints

  * the profile histogram: how many cells each gate answers, split into the half
    pass 68 already fired on (`genLocal=0 iface=0`) and the half THIS pass cuts
    open (`genLocal=1` or `iface=1`);
  * `sps` vs `spsAny`: `sps` is the shipped binary's own firing decision at the
    site, `spsAny` the PREDICATE's answer recomputed for every whole-name-Lhs
    cell whatever the gates said — so a gate that hides a corpus site cannot;
  * the MOVER SET BY NAME: every (test, mode) holding a cell the cut fires on.
    That list is the a-priori prediction the byte gate is scored against.

An invocation that did not compile is NOT dropped: its rc rides on every row.

usage: cenjoin71.py <cells.tsv> [more.tsv ...]
"""
import collections
import sys

prof = collections.Counter()
movers = collections.defaultdict(set)
newfire = collections.defaultdict(set)
rcbad = collections.Counter()
tests = set()
nogen = 0

for path in sys.argv[1:]:
    for line in open(path):
        f = line.rstrip('\n').split('\t')
        if len(f) < 4:
            continue
        name, mode, rc, body = f[0], f[1], f[2], f[3]
        tests.add(name)
        if body == 'NO-GEN-SCOPE-CA':
            nogen += 1
            continue
        kv = dict(p.split('=', 1) for p in body.split()[2:] if '=' in p)
        if rc != 'rc=0':
            rcbad[rc] += 1
        plain = kv.get('plainLhs') == '1'
        gen = kv.get('genLocal') == '1'
        iface = kv.get('iface') == '1'
        sps = kv.get('sps') == '1'
        any_ = kv.get('spsAny') == '1'
        if not plain:
            prof['plainLhs=0 (the landed Lhs fence declines)'] += 1
            continue
        half = 'CUT-OPEN' if (gen or iface) else 'PASS-68 HALF'
        if sps:
            prof[f'{half}  sps=1  THE LAW FIRES'] += 1
            movers[name].add(mode)
            if gen or iface:
                newfire[name].add(mode)
        elif any_:
            prof[f'{half}  sps=0 spsAny=1 (an earlier law owns the Rhs)'] += 1
        else:
            prof[f'{half}  sps=0 (the PREDICATE declines)'] += 1

tot = sum(prof.values())
print(f'tests censused                 {len(tests)}')
print(f'invocations with NO gen-scope cont_assign  {nogen}')
print(f'cells reaching the site        {tot}')
for k in sorted(prof):
    print(f'  {k:60s} {prof[k]}')
if rcbad:
    print('NON-ZERO rc (error recovery, not golden):',
          ' '.join(f'{k}:{v}' for k, v in sorted(rcbad.items())))
print(f'\nA-PRIORI MOVER SET (the law fires): {len(movers)} tests')
for n in sorted(movers):
    print(f'  MOVER {n} {sorted(movers[n])}')
print(f'of which NEWLY fired by the cut: {len(newfire)} tests')
for n in sorted(newfire):
    print(f'  NEWFIRE {n} {sorted(newfire[n])}')
