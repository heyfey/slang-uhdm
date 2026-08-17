#!/usr/bin/env python3
"""Refinement of the under-fire check: attribute every source FILE holding a
nested-replication conn actual to the TEST that compiles it, by walking up to the
nearest ancestor directory containing a `<Name>.sl` command file (which is how
verify_golden.py enumerates the surelog corpus).  The first pass attributed by
top-level directory, which lumped whole third-party TREES (black-parrot, oh,
YosysBigSim, ...) under names that are not test rows at all.
"""
import os
import re
import sys

ROOTS = [os.path.expanduser('~/git-repos/Surelog/tests'),
         os.path.expanduser('~/git-repos/Surelog/third_party/tests')]
CONN = re.compile(r'\.\s*[A-Za-z_]\w*\s*\(')
REPL = re.compile(r'\{\s*[\w:$.+\-*/\s()\[\]\']+?\s*\{')


def actuals(src):
    for m in CONN.finditer(src):
        i = m.end() - 1
        d = 0
        j = i
        while j < len(src):
            c = src[j]
            if c == '(':
                d += 1
            elif c == ')':
                d -= 1
                if d == 0:
                    break
            j += 1
        yield src[i + 1:j]


def top(s):
    out, d = [], 0
    for c in s:
        if c in '{([':
            d += 1
        elif c in '})]':
            d -= 1
        elif d == 0:
            out.append(c)
    return ''.join(out)


def nested_repl(a):
    if not REPL.search(a):
        return False
    s = a.strip()
    if s.startswith('{') and s.endswith('}'):
        inner = s[1:-1].strip()
        if REPL.match(s) and not inner.startswith('{') and ',' not in top(inner):
            return False
    return True


sl_of = {}


def test_for(path):
    d = os.path.dirname(path)
    while len(d) > 5:
        if d not in sl_of:
            try:
                sl_of[d] = [f[:-3] for f in os.listdir(d) if f.endswith('.sl')]
            except OSError:
                sl_of[d] = []
        if sl_of[d]:
            return sl_of[d]
        d = os.path.dirname(d)
    return []


hits = {}
for root in ROOTS:
    for dp, _dn, fn in os.walk(root):
        for f in fn:
            if not f.endswith(('.sv', '.v', '.svh', '.vh')):
                continue
            p = os.path.join(dp, f)
            try:
                if os.path.getsize(p) > 8_000_000:
                    continue
                src = open(p, errors='replace').read()
            except OSError:
                continue
            if '{' not in src:
                continue
            n = sum(1 for a in actuals(src) if nested_repl(a))
            if not n:
                continue
            for t in test_for(p) or ['<NO .sl ANCESTOR>']:
                hits.setdefault(t, [0, set()])
                hits[t][0] += n
                hits[t][1].add(os.path.relpath(p, root))

for t, (n, files) in sorted(hits.items(), key=lambda x: -x[1][0]):
    print('%-30s actuals=%-5d files=%d  e.g. %s'
          % (t, n, len(files), sorted(files)[0]))
print('TESTS WITH THE SHAPE: %d' % len(hits))
