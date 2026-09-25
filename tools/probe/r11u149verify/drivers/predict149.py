#!/usr/bin/env python3
# predict149.py <workdir> <out>: the databases § tpDefaultEndTopTwin149v can move, named from the PRISTINE (ON) databases
# before the fix sweep is read.  The fix only acts where a package typedef's DEFINITION object (uhdmallPackages) carries an
# end position that its ELABORATED twin (uhdmtopPackages, same name and start) does not: that is the trace the shared
# type-parameter end move leaves.  Predicate (wider than the law): any package-held typespec whose (name, start) has a
# different end in the two package listings.
import sys, os, re, glob, subprocess
from concurrent.futures import ThreadPoolExecutor
W, OUT = sys.argv[1], sys.argv[2]
DUMP = os.environ['UHDM_DUMP']
FENCED = set(os.environ.get('FENCED', '').split())
rx = re.compile(r'^\\_(\w+_typespec): \(([^)]*::[^)]*)\), line:(\d+:\d+), endln:(\d+:\d+)')
def one(p):
    try:
        out = subprocess.run([DUMP, p], capture_output=True, text=True, timeout=900, errors='replace').stdout
    except Exception as e:
        return p, 'ERR'
    sec = None; ends = {'all': {}, 'top': {}}
    for ln in out.split('\n'):
        if ln.startswith('|uhdmallPackages'): sec = 'all'; continue
        if ln.startswith('|uhdmtopPackages'): sec = 'top'; continue
        if ln.startswith('|uhdm'): sec = None; continue
        if sec:
            m = rx.match(ln.strip())
            if m: ends[sec].setdefault((m.group(1), m.group(2), m.group(3)), set()).add(m.group(4))
    hits = [f'{k[1]}@{k[2]} all={sorted(ends["all"][k])} top={sorted(ends["top"][k])}' for k in ends['all']
            if k in ends['top'] and ends['all'][k] != ends['top'][k]]
    return p, ';'.join(hits)
paths = sorted(glob.glob(f'{W}/surelog/*/*/slang.uhdm') + glob.glob(f'{W}/uhdm2rtlil/*/*/slang.uhdm') + glob.glob(f'{W}/probe/*.uhdm'))
paths = [p for p in paths if not any(os.path.basename(os.path.dirname(p)).startswith(f + '-') for f in FENCED)]
with ThreadPoolExecutor(3) as ex, open(OUT, 'w') as fo:
    n = 0
    for p, h in ex.map(one, paths):
        if h:
            n += 1; fo.write(p.replace(W + '/', '') + '\t' + h + '\n')
print(len(paths), 'databases scanned;', n, 'predicted')
