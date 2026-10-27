#!/usr/bin/env python3
"""Trace census of a law binary over sv-tests rows: re-runs the control's cmds.txt slang line
(the master's control sweep at the base) with LAW and R11U447_TRACE, records rc and firings.
usage: sv_trace.py <control svtests work dir> <list of rows> <law> <workdir> <out.tsv> [jobs]"""
import os, shlex, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
ctl, lst, law, wd, out = sys.argv[1:6]
jobs = int(sys.argv[6]) if len(sys.argv) > 6 else 3
rows = [l.strip() for l in open(lst) if l.strip()]
def one(p):
    key = p[:-3] if p.endswith('.sv') else p
    cf = os.path.join(ctl, key, 'cmds.txt')
    if not os.path.isfile(cf):
        return f'{p}\tNOCMDS'
    line = [l for l in open(cf) if l.startswith('slang:')]
    if not line:
        return f'{p}\tNOSLANG'
    argv = shlex.split(line[0][len('slang:'):])
    o = argv.index('-o')
    d = os.path.join(wd, key); os.makedirs(os.path.join(d, 'tr'), exist_ok=True)
    argv[0] = law; argv[o + 1] = os.path.join(d, 'law.uhdm')
    env = dict(os.environ, R11U447_TRACE=os.path.join(d, 'tr'))
    try:
        rc = subprocess.run(argv, cwd=d, env=env, stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL, stdin=subprocess.DEVNULL, timeout=900).returncode
    except subprocess.TimeoutExpired:
        rc = 'TO'
    fl = []
    for t in os.listdir(os.path.join(d, 'tr')):
        fl += [l.strip() for l in open(os.path.join(d, 'tr', t)) if not l.startswith('OUT')]
    try: os.remove(os.path.join(d, 'law.uhdm'))
    except OSError: pass
    return f'{p}\t{rc}\t{len(fl)}\t{";".join(fl)[:300]}'
with ThreadPoolExecutor(jobs) as ex, open(out, 'w') as f:
    for s in ex.map(one, rows):
        f.write(s + '\n')
