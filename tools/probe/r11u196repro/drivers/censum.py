#!/usr/bin/env python3
"""r11u196: summarise census.sh traces: per database (the OUT line, mapped to <corpus>/<mode>/<row> or probe/<case>),
the laws that fired.  usage: censum.py <census workdir> <trace dir> > predicted.txt"""
import os, re, sys, collections
W, TR = sys.argv[1:3]
fired = collections.defaultdict(collections.Counter)
for sub in ('191', '196'):
    d = os.path.join(TR, sub)
    for f in os.listdir(d):
        out = None
        for line in open(os.path.join(d, f), errors='replace'):
            line = line.rstrip('\n')
            if line.startswith('OUT '):
                out = line[4:]
                continue
            if out is None:
                continue
            fired[out][line.split(' ')[0]] += 1
def key(p):
    p = os.path.abspath(p)
    m = re.search(r'/(surelog|uhdm2rtlil)/(default|testflags)/(.+?)-[0-9a-f]{8}/', p)
    if m: return '%s/%s/%s' % m.groups()
    m = re.search(r'/probe/(.+)\.uhdm$', p)
    if m: return 'probe/' + m.group(1)
    return 'other:' + p
agg = collections.defaultdict(collections.Counter)
for out, c in fired.items():
    agg[key(out)].update(c)
for k in sorted(agg):
    print(k, ' '.join('%s=%d' % kv for kv in sorted(agg[k].items())))
