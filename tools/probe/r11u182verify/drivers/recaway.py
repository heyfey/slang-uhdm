#!/usr/bin/env python3
"""recaway.py <GW dir> [on_tag] : the order-blind record judge, usable on stage-1 cases too.  For every case dir under
the grid scratch (written by grid.py / case.sh) and every state tag T beside on.uhdm, the uhdm-strictcmp records of
golden, ON and T (each database compared with itself, so stage 1 passes and --dump-a writes its full walk; the depth
column dropped) as multisets:
  away   = records T shared with golden that ON lost      (a field the law moved away from golden: a BREAK candidate)
  toward = records ON shares with golden that T lacked    (fields the law brought to golden)
Prints one line per (case, state): rel tag away=<n> toward=<n> [first away records].  Fail-closed on $FENCED."""
import os, sys, glob, subprocess, collections, re
if len(os.environ.get('FENCED', '').split()) != 4: sys.exit('recaway.py: source drivers/env.sh first')
SC = os.environ['STRICT_CMP']
FEN = os.environ['FENCED'].split()
def ms(u):
    m = u + '.ms'
    if not os.path.exists(m) or os.path.getmtime(m) < os.path.getmtime(u):
        subprocess.run([SC, '--max', '0', '--dump-a', u + '.rec', '--dump-b', '/dev/null', u, u],
                       capture_output=True)
        c = collections.Counter(l.rstrip('\n').split('\t', 1)[1] for l in open(u + '.rec', errors='replace') if '\t' in l)
        with open(m, 'w') as f:
            for k, v in c.items(): f.write(f'{v}\t{k}\n')
        os.remove(u + '.rec')
    c = collections.Counter()
    for l in open(m, errors='replace'):
        v, k = l.rstrip('\n').split('\t', 1); c[k] = int(v)
    return c
gw = sys.argv[1]; on = sys.argv[2] if len(sys.argv) > 2 else 'on'
for w in sorted(glob.glob(f'{gw}/**/{on}.uhdm', recursive=True)):
    d = os.path.dirname(w); rel = os.path.relpath(d, gw)
    if any(re.search(rf'\b{re.escape(n)}\b', d) for n in FEN): continue
    g = glob.glob(f'{d}/gold_*/golden.uhdm')
    if not g: continue
    G = ms(g[0]); O = ms(w)
    for t in sorted(glob.glob(f'{d}/*.uhdm')):
        tag = os.path.basename(t)[:-5]
        if tag == on: continue
        T = ms(t)
        tg = T & G; og = O & G
        away = tg - O; toward = og - T
        det = ''
        if away: det = ' | ' + ' || '.join(k.replace('\t', ' ')[:160] for k in list(away)[:3])
        print(rel, tag, f'away={sum(away.values())}', f'toward={sum(toward.values())}', det)
