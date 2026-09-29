#!/usr/bin/env python3
"""det.py <binary> <tag> <draws> <rows...>: run slang-uhdm on each row-mode's harness command (the `slang:` line of a
gate sweep's cmds.txt under $SWEEP, cwd = the test dir from verify_golden's discovery) <draws> times concurrently;
print the md5 multiset per row-mode.  Outputs under $DET (default /tmp/v11u223_det/<tag>).  Fail closed on FENCED."""
import os, sys, re, shlex, subprocess, hashlib, glob, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('det.py: FENCED')
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
SWEEP = os.environ.get('SWEEP', '/tmp/v11u223_wP')
import verify_golden as vg
b, tag, n = sys.argv[1], sys.argv[2], int(sys.argv[3]); rows = sys.argv[4:]
for r in rows:
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', r) for f in F): sys.exit('fenced row refused')
tests = vg.discover_surelog('^(' + '|'.join(rows) + ')$')
out = os.path.join(os.environ.get('DET', '/tmp/v11u223_det'), tag); os.makedirs(out, exist_ok=True)
for r in rows:
    dirpath = tests[r][0]
    for m in ('default', 'testflags'):
        ds = glob.glob(f'{SWEEP}/surelog/{m}/{r}-*/cmds.txt')
        if not ds: continue
        line = [l for l in open(ds[0]) if l.startswith('slang:')]
        if not line: continue
        argv = shlex.split(line[0][len('slang:'):])
        procs = []
        for i in range(n):
            o = f'{out}/{r}.{m}.{i}.uhdm'
            if os.path.exists(o): os.remove(o)
            a = [b] + argv[1:]; a[a.index('-o') + 1] = o
            procs.append((o, subprocess.Popen(a, cwd=dirpath, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)))
        hs = collections.Counter()
        for o, p in procs:
            rc = p.wait()
            hs[(hashlib.md5(open(o, 'rb').read()).hexdigest()[:8] if os.path.exists(o) else 'NONE') + f'/rc{rc}'] += 1
        print(tag, r, m, dict(hs), flush=True)
