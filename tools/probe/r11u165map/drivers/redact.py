#!/usr/bin/env python3
"""Write every slang-fenced test name as FENCED_<n> in every file under a
directory (contents and file names), so no artifact spells a fenced name. The
names are read from RESUME.md's non-negotiables bullet (the backticked names on
the 'slang-fenced tests' lines), never spelled here. Whole-word match, so a
superstring test name is left alone. Args: <repo> <dir or file> [...]"""
import os, re, sys
repo = sys.argv[1]
txt = open(os.path.join(repo, 'RESUME.md')).read()
m = re.search(r'The four slang-fenced tests(.*?)are NEVER dispatched', txt, re.S)
names = re.findall(r'`([A-Za-z_][A-Za-z0-9_]*)`', m.group(1))
assert len(names) == 4, len(names)
seen = {}
def sub(s, fname=False):
    def rep(mm):
        n = mm.group(0)
        if n not in seen: seen[n] = f'FENCED_{len(seen) + 1}'
        return seen[n]
    b = r'A-Za-z0-9' if fname else r'A-Za-z0-9_'   # a file name joins its parts with '_'
    return re.sub(r'(?<![' + b + r'])(' + '|'.join(names) + r')(?![' + b + r'])', rep, s)
nf = 0
def walk(d):
    if os.path.isfile(d): yield os.path.dirname(d) or '.', [os.path.basename(d)]
    else:
        for dp, _, fs in os.walk(d): yield dp, fs
for d in sys.argv[2:]:
    for dp, fs in walk(d):
        for f in fs:
            p = os.path.join(dp, f)
            try: s = open(p, encoding='utf-8').read()
            except (UnicodeDecodeError, IsADirectoryError): continue
            t = sub(s)
            if t != s: open(p, 'w', encoding='utf-8').write(t); nf += 1
            nn = sub(f, True)
            if nn != f: os.rename(p, os.path.join(dp, nn)); nf += 1
print('redacted', nf, 'files;', len(seen), 'fenced name(s) met')
