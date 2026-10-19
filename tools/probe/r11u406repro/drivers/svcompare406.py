#!/usr/bin/env python3
"""svcompare406.py <fresh svtests.csv> <baseline golden_svtests.csv>: scripts/check_svtests.py's
regression/conversion/change rules applied to a csv the stage already wrote (the stage read the
main tree's baseline, which moved under the run when pass 403 landed)."""
import csv, sys
sys.path.insert(0, '/tmp/wt_r11u406/scripts')
import check_svtests as cs
fresh = {r['case']: r for r in csv.DictReader(open(sys.argv[1]))}
base = {r['case']: r for r in csv.DictReader(open(sys.argv[2]))}
reg, conv, chg, counts = [], [], [], {}
for c, b in base.items():
    old = b['status']; f = fresh.get(c)
    st = f['status'] if f else 'MISSING'; sv = f['strict'] if f else ''
    counts[st] = counts.get(st, 0) + 1
    if st == 'MISSING': reg.append((c, old, st)); continue
    if st == old:
        if st == 'STRICT_NOTEQUAL' and sv != b['strict']: chg.append((c, old + ' ' + b['strict'], st + ' ' + sv))
        continue
    if old in cs.ACCEPTING and st not in cs.ACCEPTING and st != 'TIMEOUT': reg.append((c, old, st)); continue
    ro, rn = cs.RANK.get(old, 1), cs.RANK.get(st, 1)
    if st == 'TIMEOUT' or old == 'TIMEOUT': chg.append((c, old, st)); continue
    if rn < ro: reg.append((c, old, st))
    elif rn > ro and st in ('EQUAL', 'STRICT_NOTEQUAL', 'DIFFERENT', 'SLANG_ONLY'): conv.append((c, old, st))
    else: chg.append((c, old, st))
for x in reg: print('REGRESSION %s: %s -> %s' % x)
for x in conv: print('CONVERSION %s: %s -> %s' % x)
for x in chg: print('CHANGE %s: %s -> %s' % x)
print('sv-tests: ' + ' '.join(f'{k}={v}' for k, v in sorted(counts.items())) + f' (of {len(base)})')
print(f'regressions={len(reg)} conversions={len(conv)} changes={len(chg)}')
