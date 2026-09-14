#!/usr/bin/env python3
"""v11u32 independent A-PRIORI mover prediction, from the SOURCES alone.

Law A/B candidate: a design that declares `parameter type <N>` or
`typedef enum ... <N>;` and then writes a declaration `<N> [ ... ] <ident>` —
a NAME carrying a packed dimension.  (Law A also reaches the dimension-less
type-parameter cell, but `portTypeParam` already served that one in the
pristine emitter, so it cannot move.)

Law C candidate: a typedef name that appears as a `type` parameter ARGUMENT of
a child instance (`#(.P(<N>))` or `#(<N>)`) and also types a declaration in the
same design.

Both are deliberate SUPERSETS (no elaboration, no header/ANSI test): a mover
outside the union would refute the law's stated reach.
"""
import os
import re
import sys

ROOT = sys.argv[1]
SRC = re.compile(r'.*\.(sv|svh|v|vh)$')
TP = re.compile(r'\bparameter\s+type\s+([A-Za-z_]\w*)')
TDENUM = re.compile(r'\btypedef\s+enum\b[^;]*?\b([A-Za-z_]\w*)\s*;', re.S)
TDANY = re.compile(r'\btypedef\b[^;]*?\b([A-Za-z_]\w*)\s*;', re.S)
TYPEARG = re.compile(r'#\s*\([^)]*?\b([A-Za-z_][\w:]*)\s*\)', re.S)

ab, c = [], []
for name in sorted(os.listdir(ROOT)):
    d = os.path.join(ROOT, name)
    if not os.path.isdir(d):
        continue
    text = ''
    for dp, _, fs in os.walk(d):
        for f in fs:
            if SRC.match(f):
                try:
                    text += open(os.path.join(dp, f), errors='replace').read() + '\n'
                except OSError:
                    pass
    if not text:
        continue
    names = set(TP.findall(text)) | set(TDENUM.findall(text))
    for n in names:
        if re.search(r'\b' + re.escape(n) + r'\s*\[[^;]*\]\s*[A-Za-z_]\w*\s*[;,)]', text):
            ab.append((name, n))
            break
    tds = set(TDANY.findall(text))
    args = set(a.split('::')[-1] for a in TYPEARG.findall(text))
    shared = tds & args
    for n in shared:
        if re.search(r'(^|[\s;)])' + re.escape(n) + r'\s+[A-Za-z_]\w*\s*[;=\[]', text, re.M):
            c.append((name, n))
            break

print('LAW A/B candidates (%d):' % len(ab))
for t, n in ab:
    print('   ', t, '   via', n)
print('LAW C candidates (%d):' % len(c))
for t, n in c:
    print('   ', t, '   via', n)
print('UNION:', len(set(x[0] for x in ab) | set(x[0] for x in c)))
