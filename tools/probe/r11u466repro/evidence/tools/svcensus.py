#!/usr/bin/env python3
"""svcensus.py <law binary> <fenced file> <out dir> <control svtests work dir> [jobs]
Runs the law binary's slang side of every sv-tests row with the arguments the
control sweep recorded (cmds.txt 'slang:' line, binary and -o replaced), with
R11U466_TRACE set; prints every row that fired a law, and whether its bytes
differ from the control's kept database when the control kept one.
Rows are fence-filtered by path before any file of a row is read."""
import hashlib, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
law, fenced_f, out, ctl = sys.argv[1:5]
jobs = int(sys.argv[5]) if len(sys.argv) > 5 else 3
fenced = [l.strip() for l in open(fenced_f) if l.strip()]
rows = []
for dp, dn, fn in os.walk(ctl):
    if 'cmds.txt' in fn:
        rel = os.path.relpath(dp, ctl)
        if any(f in rel for f in fenced):
            continue
        if os.environ.get('SVC_FILTER') and not __import__('re').search(os.environ['SVC_FILTER'], rel):
            continue
        rows.append(rel)
rows.sort()
def md5(p):
    try:
        return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except OSError:
        return None
def run(rel):
    line = [l for l in open(os.path.join(ctl, rel, 'cmds.txt')) if l.startswith('slang:')]
    if not line:
        return rel, 'nocmd', False, []
    argv = line[0].split()[1:]
    i = argv.index('-o')
    argv = argv[1:i] + argv[i + 2:]
    w = os.path.join(out, rel); tr = os.path.join(w, 'tr'); os.makedirs(tr, exist_ok=True)
    for f in os.listdir(tr): os.unlink(os.path.join(tr, f))
    o = os.path.join(w, 'slang.uhdm')
    if os.path.exists(o): os.unlink(o)
    try:
        r = subprocess.run([law] + argv + ['-o', o], cwd=w, env=dict(os.environ, R11U466_TRACE=tr),
                           stdin=subprocess.DEVNULL, capture_output=True, timeout=600)
        rc = r.returncode
    except subprocess.TimeoutExpired:
        rc = 'TIMEOUT'
    fires = sorted(set(l.split()[0] for f in os.listdir(tr) for l in open(os.path.join(tr, f)) if not l.startswith('OUT ')))
    c = md5(os.path.join(ctl, rel, 'slang.uhdm'))
    moved = 'nokept' if c is None else ('MOVED' if md5(o) != c else 'same')
    if os.path.exists(o) and not fires and not os.environ.get('SVC_KEEP'):
        os.unlink(o)
    return rel, rc, moved, fires
with ThreadPoolExecutor(jobs) as ex:
    res = list(ex.map(run, rows))
for rel, rc, moved, fires in res:
    if fires or moved == 'MOVED':
        print(rel, 'rc=%s' % rc, moved, ','.join(fires))
print('rows', len(res), file=sys.stderr)
