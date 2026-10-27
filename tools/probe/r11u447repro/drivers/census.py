#!/usr/bin/env python3
"""Trace census of a law binary over a list of single-file cases (fence-filtered list):
runs LAW <file> --single-unit --nobuiltin in the file's directory with R11U447_TRACE set,
records rc and the firing lines; with a second binary (PRIS) the rows that fire are rerun on it
and the md5 and rc of both outputs compared.
usage: census.py <list> <law> <pris> <workdir> <out.tsv> [jobs]"""
import hashlib, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
lst, law, pris, wd, out = sys.argv[1:6]
jobs = int(sys.argv[6]) if len(sys.argv) > 6 else 3
root = os.getcwd()
rows = [l.strip() for l in open(lst) if l.strip()]
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()[:8]
    except OSError: return 'NONE'
def run(b, f, o, tr):
    for p in (o,):
        if os.path.exists(p): os.remove(p)
    env = dict(os.environ)
    if tr: env['R11U447_TRACE'] = tr
    try:
        return subprocess.run([b, os.path.basename(f), '--single-unit', '--nobuiltin', '-o', o],
                              cwd=os.path.join(root, os.path.dirname(f)), env=env,
                              stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                              stdin=subprocess.DEVNULL, timeout=300).returncode
    except subprocess.TimeoutExpired:
        return 'TO'
def one(i_f):
    i, f = i_f
    d = os.path.join(wd, str(i)); tr = os.path.join(d, 'tr'); os.makedirs(tr, exist_ok=True)
    for t in os.listdir(tr): os.remove(os.path.join(tr, t))
    o = os.path.join(d, 'law.uhdm')
    rc = run(law, f, o, tr)
    fl = []
    for t in os.listdir(tr):
        fl += [l.strip() for l in open(os.path.join(tr, t)) if not l.startswith('OUT')]
    if not fl:
        if os.path.exists(o): os.remove(o)
        return None
    po = os.path.join(d, 'pris.uhdm')
    prc = run(pris, f, po, None)
    return f'{f}\t{prc}\t{rc}\t{md5(po)}\t{md5(o)}\t{len(fl)}\t{";".join(fl)[:300]}'
n = 0
with ThreadPoolExecutor(jobs) as ex, open(out, 'w') as fo:
    for s in ex.map(one, enumerate(rows)):
        n += 1
        if s: fo.write(s + '\n'); fo.flush()
print(n, 'files')
