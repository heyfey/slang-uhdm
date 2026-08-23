#!/usr/bin/env python3
"""pred106.py <workdir> <shapefiles.txt> : a-priori mover prediction.
For each database in the sweep workdir, read its OWN cmds.txt slang line, take
the source files and every +incdir+ root, and resolve `include directives
TRANSITIVELY; a database is predicted to move when the closure contains a file
carrying the § unsizedBasedParamRhsSize106 declaration shape."""
import os, re, sys, shlex
WD, SH = sys.argv[1], sys.argv[2]
shape = set(os.path.realpath(l.strip()) for l in open(SH) if l.strip())
INC = re.compile(r'^\s*`include\s+"([^"]+)"', re.M)
_cache = {}
def incs(path):
    if path in _cache: return _cache[path]
    try: t = open(path, errors='replace').read()
    except Exception: t = ''
    r = INC.findall(t); _cache[path] = r; return r
out = {}
for mode in ('default','testflags'):
    md = os.path.join(WD, mode)
    if not os.path.isdir(md): continue
    for db in sorted(os.listdir(md)):
        c = os.path.join(md, db, 'cmds.txt')
        if not os.path.exists(c): continue
        line = None
        for l in open(c, errors='replace'):
            if l.startswith('slang:'): line = l[6:].strip(); break
        if not line: continue
        try: toks = shlex.split(line)
        except Exception: toks = line.split()
        srcs, incdirs = [], []
        for t in toks:
            if t.startswith('+incdir+'):
                incdirs += [p for p in t[len('+incdir+'):].split('+') if p]
            elif t.endswith(('.sv','.v','.svh','.vh')) and os.path.exists(t):
                srcs.append(os.path.realpath(t))
        cwd = os.path.dirname(os.path.join(md, db))
        roots = [os.path.realpath(d) for d in incdirs if os.path.isdir(d)]
        roots += sorted({os.path.dirname(s) for s in srcs})
        seen, stack, found = set(), list(srcs), []
        while stack:
            f = stack.pop()
            if f in seen: continue
            seen.add(f)
            if f in shape: found.append(f)
            for i in incs(f):
                for r in roots + [os.path.dirname(f)]:
                    cand = os.path.realpath(os.path.join(r, i))
                    if os.path.exists(cand):
                        stack.append(cand); break
        if found:
            out.setdefault(mode, []).append((db.split('-')[0], sorted({os.path.basename(x) for x in found})))
for mode in sorted(out):
    for name, fs in sorted(out[mode]):
        print(f'{mode} {name}  {" ".join(fs)}')
    print(f'-- {mode}: {len(out[mode])} databases predicted')
