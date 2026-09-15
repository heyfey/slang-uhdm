#!/usr/bin/env python3
# v11u43 VERIFIER a-priori mover census.  Re-runs the NEUTRAL binary
# (R11U43_OFF=1) with the law's cell trace over each corpus row's EXACT
# recorded argv.  Binary from argv, never SLANG_UHDM.  cwd is resolved by
# LOCATING the recorded source file under the corpus root (the harness runs
# with cwd=dirpath), so no name-to-dir guess is made.
import os, re, shlex, subprocess, sys, collections
binpath, workroot, corpusroot, out = sys.argv[1:5]

# index every basename under the corpus root -> list of dirs
idx = collections.defaultdict(list)
for dp, dn, fn in os.walk(corpusroot):
    dn[:] = [d for d in dn if d not in ('.git',)]
    for f in fn:
        idx[f].append(dp)

rows, n, nocmd, cells, unresolved = [], 0, 0, 0, 0
for mode in sorted(os.listdir(workroot)):
    mroot = os.path.join(workroot, mode)
    if not os.path.isdir(mroot): continue
    for wd in sorted(os.listdir(mroot)):
        d = os.path.join(mroot, wd); cf = os.path.join(d, 'cmds.txt')
        if not os.path.isfile(cf): nocmd += 1; continue
        m = re.search(r'^slang:\s+(.*)$', open(cf).read(), re.M)
        if not m: nocmd += 1; continue
        argv = shlex.split(m.group(1)); n += 1
        name = wd.rsplit('-', 1)[0]
        # resolve cwd: first relative (non-flag, existing-basename) arg
        cwd = None
        for a in argv[1:]:
            if a.startswith('-') or os.path.isabs(a): continue
            b = os.path.basename(a)
            cands = [p for p in idx.get(b, []) if os.path.isfile(os.path.join(p, a))]
            exact = [p for p in cands if os.path.basename(p) == name]
            if exact: cwd = exact[0]; break
            if len(cands) == 1: cwd = cands[0]; break
            if cands: cwd = sorted(cands)[0]; break
        if cwd is None:
            cwd = corpusroot; unresolved += 1
        argv = [binpath] + argv[1:]
        try:
            i = argv.index('-o'); argv[i+1] = os.path.join(d, 'vpred.uhdm')
        except ValueError: pass
        env = dict(os.environ, R11U43_OFF='1', R11U43_CELLDBG='1')
        try:
            r = subprocess.run(argv, cwd=cwd, capture_output=True, text=True, timeout=1800, env=env)
            err, rc = r.stderr, r.returncode
        except subprocess.TimeoutExpired:
            err, rc = '', 'TIMEOUT'
        cc = re.findall(r'R11U43CELL site=(\S+) .*claim=(\d)', err)
        cells += len(cc)
        hit = [s for s, c in cc if c == '1']
        if hit: rows.append((name, mode, len(cc), len(hit), ','.join(sorted(set(hit)))))
        try: os.unlink(os.path.join(d, 'vpred.uhdm'))
        except OSError: pass
with open(out, 'w') as f:
    f.write('binary %s\nworkroot %s\ncorpusroot %s\n' % (binpath, workroot, corpusroot))
    f.write('rows with a slang cmd: %d  (no slang line: %d)  (cwd unresolved: %d)\n' % (n, nocmd, unresolved))
    f.write('CELL trace lines seen (POSITIVE CONTROL): %d\n' % cells)
    for r in sorted(rows): f.write('PREDICTED %s %s cells=%d claims=%d sites=%s\n' % r)
    f.write('PREDICTED MOVER TESTS: %d\n' % len(rows))
sys.stdout.write(open(out).read())
