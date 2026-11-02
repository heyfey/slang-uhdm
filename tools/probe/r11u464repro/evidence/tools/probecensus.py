#!/usr/bin/env python3
"""probecensus.py <law binary> <fenced file> <out dir> <control probe dir> [jobs]
Runs the law binary over every tests/probe case (check_probe.py's arguments)
with R11U464_TRACE set and compares the bytes with the control's database.
Paths are fence-filtered before any case is opened."""
import glob, hashlib, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
law, fenced_f, out, ctl = sys.argv[1:5]
jobs = int(sys.argv[5]) if len(sys.argv) > 5 else 3
root = os.environ.get('PROBE_ROOT', '/home/heyfey/git-repos/slang-uhdm/tests/probe')
fenced = [l.strip() for l in open(fenced_f) if l.strip()]
rels = []
for g in sorted(glob.glob(os.path.join(root, '**', 'dut.sv'), recursive=True)):
    rel = os.path.relpath(os.path.dirname(g), root)
    if any(f in rel for f in fenced):
        continue
    rels.append(rel)
def md5(p):
    try:
        return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except OSError:
        return 'none'
def run(rel):
    key = rel.replace('/', '__')
    w = os.path.join(out, key); os.makedirs(w, exist_ok=True)
    o = os.path.join(w, 'slang.uhdm'); tr = os.path.join(w, 'tr'); os.makedirs(tr, exist_ok=True)
    for f in os.listdir(tr): os.unlink(os.path.join(tr, f))
    if os.path.exists(o): os.unlink(o)
    r = subprocess.run([law, 'dut.sv', '--single-unit', '--nobuiltin', '-o', o],
                       cwd=os.path.join(root, rel), env=dict(os.environ, R11U464_TRACE=tr),
                       stdin=subprocess.DEVNULL, capture_output=True, timeout=900)
    fires = sorted(set(l.split()[0] for f in os.listdir(tr) for l in open(os.path.join(tr, f)) if not l.startswith('OUT ')))
    moved = md5(o) != md5(os.path.join(ctl, key + '.uhdm'))
    return rel, r.returncode, moved, fires
with ThreadPoolExecutor(jobs) as ex:
    res = list(ex.map(run, rels))
for rel, rc, moved, fires in res:
    if moved or fires:
        print(rel, 'rc=%d' % rc, 'MOVED' if moved else 'same', ','.join(fires))
print('cases', len(res), file=sys.stderr)
