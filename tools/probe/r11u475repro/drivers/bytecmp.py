#!/usr/bin/env python3
"""bytecmp.py: the law8 sweep's slang.uhdm per row against the census's pristine
(A) database of the same row (same cwd and arguments), fence-filtered, with a
negative control (one byte flipped in memory must make every row a mover)."""
import os, sys, glob
fence = [l.strip() for l in open('/tmp/r11u475_fenced.txt') if l.strip()]
SW, CE = '/tmp/r11u475_sw', '/tmp/r11u475_census/db'
lanes = {('surelog', 'default'): 'surelog.d', ('surelog', 'testflags'): 'surelog.t',
         ('uhdm2rtlil', 'default'): 'uhdm2rtlil.d', ('uhdm2rtlil', 'testflags'): 'uhdm2rtlil.t'}
for (corp, mode), lane in lanes.items():
    n = same = diff = miss = neg = 0; movers = []
    for d in sorted(glob.glob(f'{SW}/{corp}/{mode}/*/slang.uhdm')):
        name = os.path.basename(os.path.dirname(d)).rsplit('-', 1)[0]
        if any(f in name for f in fence): continue
        a = f'{CE}/{lane}/{name}.A.uhdm'
        if not os.path.exists(a): miss += 1; continue
        x = open(d, 'rb').read(); y = open(a, 'rb').read(); n += 1
        if x == y: same += 1
        else: diff += 1; movers.append(name)
        z = bytearray(y); z[len(z)//2] ^= 1
        if bytes(z) != x: neg += 1
    print(f'{corp}/{mode}: compared={n} identical={same} movers={diff} no-census-db={miss} negative-control-flagged={neg}/{n}', movers[:20])
n = same = diff = miss = neg = 0; movers = []
for d in sorted(glob.glob(f'{SW}/downstream/*/slang/*.uhdm')) or sorted(glob.glob(f'{SW}/downstream/*/*/in.uhdm')):
    pass
print('downstream layout:', os.listdir(f'{SW}/downstream')[:3])
