#!/usr/bin/env python3
# pairjudge.py <cw dir> <refTag> <newTag> ...: the worse.py rule between two tags of one case workdir
import sys, importlib.util
spec = importlib.util.spec_from_file_location('score', '/tmp/wt_r11u149/tools/probe/r11u149verify/drivers/score.py')
src = open('/tmp/wt_r11u149/tools/probe/r11u149verify/drivers/score.py').read()
ns = {}; exec(src.split('G = {}')[0], ns)   # recs() and judge() only
w = sys.argv[1]; tags = sys.argv[2:]
import hashlib, os
md5 = lambda t: hashlib.md5(open(f'{w}/{t}.uhdm', 'rb').read()).hexdigest()
out = []
for a, b in zip(tags[::2], tags[1::2]):
    v = 'same-bytes' if md5(a) == md5(b) else ns['judge'](ns['recs'](f'{w}/{a}.strict'), ns['recs'](f'{w}/{b}.strict'))
    out.append(f'{a}->{b}={v}')
print(os.path.basename(w), ' '.join(out))
