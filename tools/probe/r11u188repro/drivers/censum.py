#!/usr/bin/env python3
"""r11u188: summarize a census trace dir: per database (the OUT line), the r11u188 laws that fired (count).
Every firing is a PREDICTED byte mover (a superset: a firing may write the value a field already had).
Prints `<row>\t<mode>\t<corpus>\t<law:count ...>`; a probe case prints `<case>\tprobe\tprobe\t...`.
usage: censum.py <trace dir>"""
import sys, os, re, collections
d = sys.argv[1]
per = collections.defaultdict(collections.Counter)
for fn in os.listdir(d):
    out = None
    for line in open(os.path.join(d, fn), errors='replace'):
        line = line.rstrip('\n')
        if line.startswith('OUT '):
            out = line[4:]; continue
        if not out: continue
        per[out][line.split(' ')[0]] += 1
def key(p):
    m = re.search(r'/(surelog|uhdm2rtlil)/(default|testflags)/([^/]+)-[0-9a-f]{8}/', p)
    if m: return f'{m.group(3)}\t{m.group(2)}\t{m.group(1)}'
    m = re.search(r'/probe/([^/]+)\.uhdm$', p)
    if m: return f'{m.group(1).replace("__", "/")}\tprobe\tprobe'
    return p + '\t?\t?'
for out in sorted(per, key=key):
    print(key(out) + '\t' + ' '.join(f'{k}:{v}' for k, v in sorted(per[out].items())))
