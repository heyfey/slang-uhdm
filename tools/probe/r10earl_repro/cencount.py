#!/usr/bin/env python3
"""Bucket an r10earl4h census by (failLhs kind+name+loc, failRhs kind+name+loc).

usage: cencount.py <census.txt>   -> per-class counts, listing section + heads.
"""
import re, sys, collections

txt = open(sys.argv[1]).read().splitlines()
sect = None
heads = []          # (section, headname, lhs, rhs)
cur = None
for ln in txt:
    if ln.startswith('== '):
        sect = ln[3:].split(' SIZE')[0]
        print(ln)
        continue
    m = re.match(r'\s*HEAD (\S+) r=(-?\d+)', ln)
    if m:
        cur = [sect, m.group(1), m.group(2), None, None]
        heads.append(cur)
        continue
    m = re.match(r'\s+failLhs (.*)', ln)
    if m and cur:
        cur[3] = m.group(1)
        continue
    m = re.match(r'\s+failRhs (.*)', ln)
    if m and cur:
        cur[4] = m.group(1)


def norm(s):
    if s is None:
        return '?'
    s = re.sub(r'/[^ ]*/', '', s)          # strip dir path
    s = re.sub(r'uid=\d+', 'uid=N', s)
    return s


c = collections.Counter()
ex = {}
for sec, hd, r, lhs, rhs in heads:
    k = (sec, norm(lhs), norm(rhs))
    c[k] += 1
    ex.setdefault(k, []).append(hd)
print('\n== CLASSES (%d heads, %d classes)' % (len(heads), len(c)))
for (sec, lhs, rhs), n in c.most_common():
    print('%3d  [%s]\n     L: %s\n     R: %s\n     e.g. %s' %
          (n, sec, lhs, rhs, ', '.join(ex[(sec, lhs, rhs)][:4])))
