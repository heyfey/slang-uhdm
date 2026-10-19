import csv, sys
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
from check_svtests import RANK, ACCEPTING
base = {r['case']: r for r in csv.DictReader(open(sys.argv[1]))}
fresh = {r['case']: r for r in csv.DictReader(open(sys.argv[2]))}
reg, conv, chg, counts = [], [], [], {}
for c in base:
    old = base[c]['status']; st = fresh[c]['status'] if c in fresh else 'MISSING'; sv = fresh.get(c, {}).get('strict', '')
    counts[st] = counts.get(st, 0) + 1
    if st == 'MISSING': reg.append((c, old, st)); continue
    if st == old:
        if st == 'STRICT_NOTEQUAL' and sv != base[c]['strict']: chg.append((c, old + ' ' + base[c]['strict'], st + ' ' + sv))
        continue
    if old in ACCEPTING and st not in ACCEPTING and st != 'TIMEOUT': reg.append((c, old, st)); continue
    ro, rn = RANK.get(old, 1), RANK.get(st, 1)
    if st == 'TIMEOUT' or old == 'TIMEOUT': chg.append((c, old, st)); continue
    if rn < ro: reg.append((c, old, st))
    elif rn > ro and st in ('EQUAL', 'STRICT_NOTEQUAL', 'DIFFERENT', 'SLANG_ONLY'): conv.append((c, old, st))
    else: chg.append((c, old, st))
for x in reg: print('REGRESSION %s: %s -> %s' % x)
for x in conv: print('CONVERSION %s: %s -> %s' % x)
for x in chg: print('CHANGE %s: %s -> %s' % x)
print('sv-tests: ' + ' '.join(f'{k}={v}' for k, v in sorted(counts.items())) + f' (of {len(base)})')
print(f'regressions={len(reg)} conversions={len(conv)} changes={len(chg)}')
