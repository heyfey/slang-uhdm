#!/usr/bin/env python3
# (r11u246) awaycases.py <case-view rel> ...: the chain-keyed away census of awayrows.py on grid case-views (the
# databases case.sh keeps under $S/g/<rel>: gold_*/golden.uhdm, pristine.uhdm, law.uhdm).  away = golden-agreeing
# records the pristine database had and the law one lost; toward = the reverse.  Case databases only (no corpus path).
import os, sys, glob, importlib.util
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('awaycases.py: source drivers/env.sh first')
H = os.path.dirname(os.path.abspath(__file__))
rels = sys.argv[1:]
ON = os.environ.get('ON_TAG', 'law')  # (v11u246) the case.sh tag compared against pristine
OFF = os.environ.get('OFF_TAG', 'pristine')
sys.argv = [sys.argv[0], '/nonexistent_off', '/nonexistent_on', '1']
src = open(os.path.join(H, 'awayrows.py')).read().split('jobs = []')[0]
g = {'__name__': 'aw', '__file__': os.path.join(H, 'awayrows.py')}; exec(compile(src, 'awayrows.py', 'exec'), g)
for rel in rels:
    d = os.path.join(os.environ['S'], 'g', rel)
    gs = glob.glob(d + '/gold_*/golden.uhdm')
    if not gs or not os.path.exists(f'{d}/{OFF}.uhdm') or not os.path.exists(f'{d}/{ON}.uhdm'):
        print(rel, 'MISSING'); continue
    (G, Gf), (Ok, Of), (Nk, Nf) = g['keyed'](gs[0]), g['keyed'](f'{d}/{OFF}.uhdm'), g['keyed'](f'{d}/{ON}.uhdm')
    away = (Ok & G) - Nk; tow = (Nk & G) - Ok
    print(f'{rel} away={sum(away.values())} toward={sum(tow.values())}' + ((' | ' + ' || '.join((k[1] + ' @ ' + k[0])[:200] for k in list(away)[:3])) if away else ''))
