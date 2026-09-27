#!/usr/bin/env python3
"""r11u186: summarize a census trace dir: per database (the OUT line), the laws that fired (count) and, for
§ lawSCopyIdOrder186, whether its triggers were REORDERED (a predicted byte mover) or kept their order.
Prints `<row-or-case key>\t<law:count ...>`; a key is the corpus row/mode (from the -o path) or the probe case.
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
        law = line.split(' ')[0]
        if law == 'lawSCopyIdOrder186':
            # `lawSCopyIdOrder186 <main|elem> <same|reorder> <triggers>`: REORDER = the triggers' address order
            # differs from their creation order (a mover); MULTI = two or more triggers in the same order (the
            # superset: another object of the same memo key may still be first in address order); else SINGLE.
            f = line.split(' ')
            law = 'lawSCopyIdOrder186:' + ('reorder' if f[2] == 'reorder' else ('multi' if int(f[3]) >= 2 else 'single'))
        per[out][law] += 1
def key(p):
    m = re.search(r'/(surelog|uhdm2rtlil)/(default|testflags)/([^/]+)-[0-9a-f]{8}/', p)
    if m: return f'{m.group(3)}\t{m.group(2)}\t{m.group(1)}'
    m = re.search(r'/probe/([^/]+)\.uhdm$', p)
    if m: return f'{m.group(1).replace("__", "/")}\tprobe\tprobe'
    return p + '\t?\t?'
for out in sorted(per, key=key):
    print(key(out) + '\t' + ' '.join(f'{k}:{v}' for k, v in sorted(per[out].items())))
