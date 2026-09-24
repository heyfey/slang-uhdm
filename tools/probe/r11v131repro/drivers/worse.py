#!/usr/bin/env python3
# worse.py <golden.uhdm> <pristine.uhdm> <law.uhdm> : record-level: any record pristine matched that law does not
import subprocess, sys, tempfile, os
SC='/tmp/v11u131_bin/strictcmp'
def recs(g, o):
    d = tempfile.mkdtemp(prefix='v11u131_w')
    a, b = d+'/a', d+'/b'
    r = subprocess.run([SC, '--dump-a', a, '--dump-b', b, g, o], capture_output=True, text=True)
    out = r.stdout.strip().splitlines()
    if not os.path.exists(a):
        return None, None, (out[-1] if out else 'ERR')
    A = open(a).read().splitlines(); B = open(b).read().splitlines()
    return A, B, (out[-1] if out else '')
g, p, l = sys.argv[1:4]
GA, PB, pv = recs(g, p)
GA2, LB, lv = recs(g, l)
if GA is None or GA2 is None:
    print('STAGE1', pv, '|', lv); sys.exit()
worse = better = 0; notes = []
n = min(len(GA), len(PB), len(LB))
for i in range(n):
    pm = GA[i] == PB[i]; lm = GA[i] == LB[i]
    if pm and not lm:
        worse += 1; notes.append(f'WORSE@{i}: G={GA[i]!r} L={LB[i]!r}')
    elif lm and not pm:
        better += 1
lens = (len(GA), len(PB), len(LB))
tag = 'WORSE' if worse else ('OK')
if len(set(lens)) > 1: tag += f' LEN{lens}'
print(tag, f'better={better} worse={worse}', '|', pv, '->', lv)
for x in notes[:6]: print('  ', x)
