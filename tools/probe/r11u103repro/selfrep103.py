#!/usr/bin/env python3
"""r11u103 same-binary REPEAT (the nondeterminism positive control): re-run a
sweep cell's recorded slang argv (cmds.txt) N times with ONE binary and print
each run's database md5 beside the sweep's own.
usage: REPO=<tree> selfrep103.py <corpus> <workdir> <scratch> <bin> <N> -- name/mode ..."""
import hashlib, os, shlex, subprocess, sys
a = sys.argv[1:]; i = a.index('--')
corpus, wd, scr, b, n = a[0], a[1], a[2], a[3], int(a[4]); rows = a[i + 1:]
sys.path.insert(0, os.path.join(os.environ.get('REPO', '.'), 'scripts'))
import verify_golden as vg
tests = vg.discover_surelog(None) if corpus == 'surelog' else vg.discover_uhdm2rtlil(None)
os.makedirs(scr, exist_ok=True)
md5 = lambda p: hashlib.md5(open(p, 'rb').read()).hexdigest()[:12] if os.path.exists(p) else 'NODB'
for r in rows:
    name, mode = r.split('/')
    dirpath = tests[name][0]
    tag = name + '-' + hashlib.sha1(dirpath.encode()).hexdigest()[:8]
    cell = os.path.join(wd, mode, tag)
    line = [l for l in open(os.path.join(cell, 'cmds.txt')) if l.startswith('slang:')]
    argv = shlex.split(line[0].split(':', 1)[1])
    outs = []
    for k in range(n):
        av = list(argv); av[0] = b
        o = os.path.join(scr, f'{name}.{mode}.rep{k}.uhdm')
        j = av.index('-o'); av[j + 1] = o
        if os.path.exists(o): os.remove(o)
        p = subprocess.run(av, cwd=dirpath, capture_output=True, text=True, timeout=1800)
        outs.append(f'rc={p.returncode}:{md5(o)}')
    print(name, mode, 'sweep=' + md5(os.path.join(cell, 'slang.uhdm')), ' '.join(outs))
