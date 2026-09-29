#!/usr/bin/env python3
# (v11u227) awaymov.py <kind> <moverlist> <dirP> <dirX> <workdir>: tools/probe/v11u202repro/drivers/away.py's
# order-blind record census (records with depth dropped, multisets; LOST = in golden and pristine, not in X) over
# a mover list. kind=corpus: each line `surelog/<mode>/<Test>-<hash>/slang.uhdm` under the byteverify mirrors,
# golden from the pristine sweep's cmds.txt (dirP's sweep: $SWP); kind=probe: each line `<rel>` (tests/probe),
# databases <dir>/<rel with / -> __>.uhdm, golden from scripts/check_probe.py's cache. Fail-closed on $FENCED.
import os, re, sys, subprocess
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('awaymov: FENCED')
R = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(R, 'scripts'))
AW = os.path.join(R, 'tools/probe/v11u202repro/drivers/away.py')
kind, lst, DP, DX, W = sys.argv[1:6]
os.makedirs(W, exist_ok=True)
if kind == 'probe':
    import check_probe as cp
    import verify_golden as vg
tot = [0, 0]
for l in open(lst):
    p = l.split()[0] if l.strip() else ''
    if not p: continue
    if any(re.search(r'(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])' % re.escape(f), p) for f in F):
        sys.exit('awaymov: fenced row refused')
    if kind == 'corpus':
        cm = open(os.path.join(os.environ['SWP'], os.path.dirname(p), 'cmds.txt')).read()
        g = re.search(r'golden cache [a-z]+ (\S+?)\)', cm).group(1) + '/golden.uhdm'
        a, b = os.path.join(DP, p), os.path.join(DX, p)
    else:
        g = vg.cache_load(cp.cache_dir(p))[1]
        n = p.replace('/', '__') + '.uhdm'
        a, b = os.path.join(DP, n), os.path.join(DX, n)
    t = os.path.join(W, p.replace('/', '_'))
    os.makedirs(t, exist_ok=True)
    out = subprocess.run([sys.executable, AW, g, a, b, t, 'v'], capture_output=True, text=True).stdout
    open(os.path.join(t, 'away.txt'), 'w').write(out)
    h = out.splitlines()[0] if out else 'NO_OUTPUT'
    m = re.search(r'lost=(\d+) gained=(\d+)', h)
    if m: tot[0] += int(m.group(1)); tot[1] += int(m.group(2))
    print(p, h)
print('TOTAL lost=%d gained=%d' % tuple(tot))
