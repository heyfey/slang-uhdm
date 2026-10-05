#!/usr/bin/env python3
# (r11u250: copied from r11u249repro/drivers)
# (r11u249: copied from r11u247repro/drivers)
# (r11u247) flatlost.py <golden> <off.uhdm> <on.uhdm>: the flat-key (depth-dropped) records that the OFF database
# shares with golden and the ON one lost, with golden / off / on counts, and the chain-key context of each in the
# three databases. Reuses awayrows.py's record cache; fail-closed on $FENCED (a path naming a fenced test is refused).
import os, re, sys, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('flatlost.py: source drivers/env.sh first')
for p in sys.argv[1:4]:
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F): sys.exit('fenced path refused')
g, o, n = sys.argv[1:4]
sys.argv = [sys.argv[0], '/nonexistent_off', '/nonexistent_on', '3']
import importlib.util
spec = importlib.util.spec_from_file_location('aw', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'awayrows.py'))
src = open(spec.origin).read().split('jobs = []')[0]
ns = {'__file__': spec.origin}; exec(compile(src, spec.origin, 'exec'), ns)
(G, Gf), (O, Of), (N, Nf) = ns['keyed'](g), ns['keyed'](o), ns['keyed'](n)
lost = (Of & Gf) - Nf
for rec, c in sorted(lost.items(), key=lambda x: -x[1]):
    print(f'LOST {c}  g={Gf[rec]} off={Of[rec]} on={Nf[rec]}  {rec[:200]}')
# per chain context of every lost flat record: golden / off / on counts where on < off
for rec in lost:
    ctx = collections.defaultdict(lambda: [0, 0, 0])
    for i, C in enumerate((G, O, N)):
        for (ch, r), c in C.items():
            if r == rec: ctx[ch][i] += c
    for ch, (a, b, c) in sorted(ctx.items(), key=lambda x: x[0]):
        if c < b: print(f'  CTX g={a} off={b} on={c}  {ch[:260]}')
