#!/usr/bin/env python3
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from score import scan, dump
root = sys.argv[1]; tag = sys.argv[2]
for a in sorted(os.listdir(root)):
    db = os.path.join(root, a, tag + '.uhdm')
    if not os.path.exists(db):
        print('%s %s NODB' % (tag, a)); continue
    try:
        t = dump(db)
    except Exception as e:
        print('%s %s DUMPFAIL %s' % (tag, a, e)); continue
    rows, seen = scan(t), []
    for r in rows:
        if r not in seen: seen.append(r)
    if not seen:
        print('%s %s NOCONST' % (tag, a))
    for r in seen:
        print('%s %s line=%s %s size=%s %s ct=%s dec=%s' % (tag, a, r[0], r[1], r[2], r[3], r[4], r[5]))
