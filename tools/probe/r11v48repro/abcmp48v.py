#!/usr/bin/env python3
"""r11v48 — does the VERIFIER FIX change any corpus cell relative to the
implementer's binary?  Runs both LIVE over every arm of a pristine workdir and
byte-compares the two databases."""
import hashlib, os, subprocess, sys, shlex, filecmp
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
import verify_golden as vg
corpus, wd, binA, binB, scratch = sys.argv[1:6]
os.makedirs(scratch, exist_ok=True)
tests = vg.discover_surelog(None) if corpus == 'surelog' else vg.discover_uhdm2rtlil(None)
h2dir = {hashlib.sha1(v[0].encode()).hexdigest()[:8]: v[0] for v in tests.values()}
same = diff = miss = 0
for root, dirs, files in os.walk(wd):
    if 'cmds.txt' not in files: continue
    base = os.path.basename(root); h = base.rsplit('-', 1)[-1]
    dirpath = h2dir.get(h)
    line = None
    for L in open(os.path.join(root, 'cmds.txt')):
        if L.startswith('slang:'): line = L[len('slang:'):].strip()
    if line is None or dirpath is None or not os.path.exists(os.path.join(root, 'slang.uhdm')):
        miss += 1; continue
    argv = shlex.split(line); key = hashlib.sha1(root.encode()).hexdigest()[:12]
    outs = []
    for i, b in enumerate((binA, binB)):
        av = list(argv); av[0] = b
        o = os.path.join(scratch, '%s.%d.uhdm' % (key, i))
        for j, a in enumerate(av):
            if a == '-o': av[j+1] = o
        subprocess.run(av, cwd=dirpath, capture_output=True, timeout=900)
        outs.append(o)
    if all(os.path.exists(o) for o in outs) and filecmp.cmp(outs[0], outs[1], shallow=False):
        same += 1
    else:
        diff += 1; print('AB-DIFF', base, flush=True)
    for o in outs:
        if os.path.exists(o): os.remove(o)
print('ARMS_COMPARED %d SAME %d DIFF %d MISSING %d' % (same+diff, same, diff, miss))
