#!/usr/bin/env python3
# (v11u298: copied from r11u298repro/drivers; scratch /tmp/v11u298_*)
# (r11u286: copied from r11u287repro/drivers)
# (r11u287: copied from r11u285repro/drivers)
# (r11u285: copied from r11u283repro/drivers)
# (r11u283: copied from r11u281repro/drivers)
# (r11u279: copied from r11u277repro/drivers)
# (r11u277: copied from r11u275repro/drivers)
# (r11u275: copied from r11u273repro/drivers)
# (r11u273: copied from r11u271repro/drivers)
# (r11u271: copied from r11u269repro/drivers)
# (r11u269: copied from r11u267repro/drivers)
# (r11u267: copied from r11u265repro/drivers)
# (r11u265: copied from r11u263repro/drivers)
# (r11u263: copied from r11u261repro/drivers)
# (r11u261: copied from r11u259repro/drivers)
# (r11u259: copied from r11u252repro/drivers)
# (r11u252) awaychain.py <golden> <pristine.uhdm> <law.uhdm>: the chain-keyed away census (awayrows.py's keys: each
# record keyed by its ancestor chain, $SCX's raw full name) for one case triple. away = golden-agreeing chain records
# pristine had and the law lost; also the flat (depth-dropped) count. Case databases only; fail-closed on $FENCED.
import os, re, sys
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('awaychain.py: source drivers/env.sh first')
for p in sys.argv[1:4]:
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F): sys.exit('fenced path refused')
g, o, n = sys.argv[1:4]
sys.argv = [sys.argv[0], '/nonexistent_off', '/nonexistent_on', '3']
spec_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'awayrows.py')
src = open(spec_path).read().split('jobs = []')[0]
ns = {'__file__': spec_path}; exec(compile(src, spec_path, 'exec'), ns)
(G, Gf), (O, Of), (N, Nf) = ns['keyed'](g), ns['keyed'](o), ns['keyed'](n)
away = (O & G) - N; tow = (N & G) - O
print(f'chain away={sum(away.values())} toward={sum(tow.values())} flat_away={sum(((Of & Gf) - Nf).values())} flat_toward={sum(((Nf & Gf) - Of).values())}')
for k, v in list(away.items())[:5]: print('  AWAY', v, (k[1] + ' @ ' + k[0])[:300])
