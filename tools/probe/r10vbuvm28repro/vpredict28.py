#!/usr/bin/env python3
"""r10vbuvm28 MOVER PREDICTOR — runs on PRISTINE artifacts ONLY (the pristine
sweep's cmds.txt source lists + the corpus sources), never on a patched sweep.

§ enumNoBaseTypespecZeroBits28 can only move a database that BOTH
  (a) contains a `$bits(` in some source it compiles, AND
  (b) declares an enum with NO base type (`enum {` / `enum  {`, i.e. the token
      after `enum` is `{` or a scope-qualified nothing) in some source.
Everything else is untouched by construction, so the measured mover set MUST be
a subset of what this prints.  Over-prediction is deliberate.

usage: vpredict28.py <pristine-sweep-workdir>
"""
import os, re, sys, collections

W = sys.argv[1]
ENUM_NOBASE = re.compile(r'\benum\s*(?://[^\n]*\n\s*)?\{')
ENUM_ANY = re.compile(r'\benum\b')
BITS = re.compile(r'\$bits\s*\(')

filecache = {}
def read(p):
    if p not in filecache:
        try:
            filecache[p] = open(p, errors='replace').read()
        except Exception:
            filecache[p] = ''
    return filecache[p]

def sources_of(cmds):
    for line in open(cmds, errors='replace'):
        if line.startswith('slang:'):
            toks = line.split()[2:]
            out = []
            for t in toks:
                if t.startswith('-'):
                    continue
                if t.endswith('.uhdm'):
                    continue
                out.append(t)
            return out
    return []

def expand(srcs, root):
    """the named sources plus every .sv/.svh/.v/.vh beside them (includes)."""
    seen = set()
    for s in srcs:
        p = s if os.path.isabs(s) else os.path.join(root, s)
        if os.path.isfile(p):
            seen.add(os.path.realpath(p))
    dirs = {os.path.dirname(p) for p in seen}
    for d in list(dirs):
        for dp, _dn, fn in os.walk(d):
            if dp.count(os.sep) - d.count(os.sep) > 2:
                continue
            for f in fn:
                if f.endswith(('.sv', '.svh', '.v', '.vh')):
                    seen.add(os.path.realpath(os.path.join(dp, f)))
    return seen

hits = []
for mode in sorted(os.listdir(W)):
    md = os.path.join(W, mode)
    if not os.path.isdir(md):
        continue
    for t in sorted(os.listdir(md)):
        cmds = os.path.join(md, t, 'cmds.txt')
        if not os.path.isfile(cmds):
            continue
        srcs = sources_of(cmds)
        if not srcs:
            continue
        root = os.path.dirname(srcs[0]) if os.path.isabs(srcs[0]) else os.path.join(md, t)
        files = expand(srcs, root)
        has_bits = has_nobase = False
        for p in files:
            txt = read(p)
            if not txt:
                continue
            if not has_bits and BITS.search(txt):
                has_bits = True
            if not has_nobase and ENUM_NOBASE.search(txt):
                has_nobase = True
            if has_bits and has_nobase:
                break
        if has_bits and has_nobase:
            hits.append('%s/%s' % (mode, t))
print('PREDICTED CANDIDATES (superset): %d' % len(hits))
for h in hits:
    print('  ' + h)
