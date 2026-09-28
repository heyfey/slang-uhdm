#!/usr/bin/env python3
"""v11u207 (from r11u207repro): summarize ctlbytes.sh by full case path: <case rel path> <pristine verdict> <law verdict> MOVED for every
case whose database moved, reading the judge output dirs /tmp/v11u207_judge/<bin>/<md5(path)[:10]> (judge.sh's key).
usage: ctlsum.py <list> [law bin name]"""
import sys, hashlib, os, re, filecmp
lst, lb = sys.argv[1], (sys.argv[2] if len(sys.argv) > 2 else 'law.bin')


def verdict(o):
    p = os.path.join(o, 'strict.txt')
    if not os.path.exists(os.path.join(o, 'ours.uhdm')):
        return 'SLANG_FAIL'
    if not os.path.exists(p):
        return 'NOSTRICT'
    t = open(p).read()
    m = re.search(r'^(STRICT_EQUAL|STRICT_NOTEQUAL|NOT_EQUAL)\s*(\S*)', t, re.M)
    if not m:
        return 'UNKNOWN'
    if m.group(1) == 'STRICT_EQUAL':
        return 'EQUAL'
    if m.group(1) == 'NOT_EQUAL':
        return 'NOT_EQUAL'
    n = re.search(r'objects_differing=(\d+)', t)
    return 'STRICT_NOTEQUAL:%s(%s)' % (m.group(2), n.group(1) if n else '?')


def rank(v):
    return 3 if v == 'EQUAL' else (2 if v.startswith('STRICT') else (1 if v == 'NOT_EQUAL' else 0))


tot = moved = better = worse = 0
for line in open(lst):
    d = line.strip()
    if not d:
        continue
    k = hashlib.md5((d + '\n').encode()).hexdigest()[:10]
    a, b = '/tmp/v11u207_judge/pris.bin/' + k, '/tmp/v11u207_judge/%s/%s' % (lb, k)
    va, vb = verdict(a), verdict(b)
    same = (os.path.exists(a + '/ours.uhdm') and os.path.exists(b + '/ours.uhdm')
            and filecmp.cmp(a + '/ours.uhdm', b + '/ours.uhdm', shallow=False))
    tot += 1
    if not same and os.path.exists(b + '/ours.uhdm'):
        moved += 1
        print(d.split('/tools/probe/')[-1], va, vb, 'MOVED')
    if rank(vb) > rank(va):
        better += 1
    if rank(vb) < rank(va):
        worse += 1
print('CASES %d MOVED %d status-better %d status-worse %d' % (tot, moved, better, worse))
