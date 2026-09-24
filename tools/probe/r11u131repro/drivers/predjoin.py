#!/usr/bin/env python3
"""predjoin.py <pred_raw.txt> <byteverify_surelog.txt> <byteverify_uhdm2rtlil.txt>:
join predict131's per-database law triggers (pristine databases) with the
byte movers of the law sweep."""
import re, sys
from collections import Counter
pred = {}
for l in open(sys.argv[1]):
    f = l.split(); pred[f[0]] = [x.split('=')[0] for x in f[1:]]
movers = set()
for c, p in (('surelog', sys.argv[2]), ('uhdm2rtlil', sys.argv[3])):
    for l in open(p):
        m = re.match(r'MOVER \./(\S+)', l)
        if m: movers.add(f'{c}/{m.group(1)}')
unpred = sorted(m for m in movers if not pred.get(m))
nomove = sorted(k for k, v in pred.items() if v and k not in movers)
bylaw = Counter(x for m in movers for x in pred.get(m, []))
print(f'movers {len(movers)}; predicted {len(movers)-len(unpred)}; unpredicted {len(unpred)}; predicted-not-moved {len(nomove)}')
print('movers by predicted law: ' + ' '.join(f'{k}={v}' for k, v in sorted(bylaw.items())))
print('predicted-not-moved by law: ' + ' '.join(f'{k}={v}' for k, v in sorted(Counter(x for k in nomove for x in pred[k]).items())))
for m in unpred: print('UNPREDICTED', m)
for k in nomove: print('PREDICTED-NOT-MOVED', k, ' '.join(pred[k]))
for m in sorted(movers): print('MOVER', m, ' '.join(pred.get(m, [])))
