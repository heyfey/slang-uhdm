#!/usr/bin/env python3
"""r11u229: predict.py <trace dir> <census workdir>: the prediction of fix.bin's byte movers from the census traces.
A database is a possible mover when § unitImportFileOrder229v saw two or more compilation-unit imports in it (a trace
line: `same` = the parse order equalled the buffer-id order in the census draw, `MOVED` = it did not); only there can
the fix's order differ from the base binary's.  Names databases in the predcheck.py format (probe/<case>,
surelog/<mode>/<test>, uhdm2rtlil/<mode>/<test>, downstream/<test>).  Fenced corpus paths are dropped unread (the
traces of the fenced rows are skipped by word boundary; fail-closed on $FENCED)."""
import os, re, sys, glob, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('predict.py: source drivers/env.sh first')
T, W = sys.argv[1:3]
def fenced(p): return any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F)
out = collections.defaultdict(collections.Counter)
for f in glob.glob(f'{T}/*.229'):
    L = open(f, errors='replace').read().splitlines()
    if not L or not L[0].startswith('OUT '): continue
    o = L[0][4:]
    if fenced(o): continue
    r = os.path.relpath(o, W) if o.startswith(W) else o
    if r.startswith('probe/'): name = 'probe/' + os.path.basename(r)[:-5].replace('__', '/')
    elif r.startswith(('surelog/', 'uhdm2rtlil/')):
        p = r.split('/'); name = f'{p[0]}/{p[1]}/{re.sub(r"-[0-9a-f]+$", "", p[2])}'
    elif r.startswith('downstream/'): name = 'downstream/' + r.split('/')[1]
    else: name = 'other/' + r
    for l in L[1:]:
        w = l.split()
        if len(w) >= 2: out[name][f'{w[0]}:{w[1]}'] += 1
for n in sorted(out): print(n, ' '.join(f'{k}x{v}' for k, v in sorted(out[n].items())))
print(f'# {len(out)} possible movers')
