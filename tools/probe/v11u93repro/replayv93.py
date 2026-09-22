#!/usr/bin/env python3
"""v11u93 rc replay: re-run the harness's own recorded slang argv (cmds.txt) for
named rows with each given binary, recording the RAW rc (rc=139/-11 = segfault).
usage: REPO=<slang-uhdm tree> replayv93.py <corpus> <workdir> <out-scratch> <bin>... -- name/mode ..."""
import hashlib, os, shlex, subprocess, sys, glob
a = sys.argv[1:]; i = a.index('--')
corpus, wd, scr = a[0], a[1], a[2]; bins = a[3:i]; rows = a[i+1:]
sys.path.insert(0, os.path.join(os.environ.get('REPO', '.'), 'scripts'))
import verify_golden as vg
tests = vg.discover_surelog(None) if corpus == 'surelog' else vg.discover_uhdm2rtlil(None)
os.makedirs(scr, exist_ok=True)
for r in rows:
    name, mode = r.split('/')
    dirpath = tests[name][0]
    tag = name + '-' + hashlib.sha1(dirpath.encode()).hexdigest()[:8]
    cm = os.path.join(wd, mode, tag, 'cmds.txt')
    line = [l for l in open(cm) if l.startswith('slang:')]
    if not line:
        print(name, mode, 'NO-SLANG-LINE'); continue
    argv = shlex.split(line[0].split(':', 1)[1])
    out = []
    for b in bins:
        av = list(argv); av[0] = b
        o = os.path.join(scr, f'{name}.{mode}.{os.path.basename(b)}.uhdm')
        k = av.index('-o'); av[k+1] = o
        if os.path.exists(o): os.remove(o)
        p = subprocess.run(av, cwd=dirpath, capture_output=True, text=True, timeout=900)
        out.append(f'{os.path.basename(b)}:rc={p.returncode}:db={"Y" if os.path.exists(o) else "N"}')
    print(name, mode, ' '.join(out))
