#!/usr/bin/env python3
"""fixgrid.py [--el] <casedir>...: the r11u173 refinement (fix.patch, $FIX) against HEAD ($LAW) per case:
states FIX (no switch), FIXOFF (R11V173_OFF=1; must equal HEAD bytes), and each refinement switch alone.
Scores FIX against HEAD with grid.py's scorer (TOWARD / AWAY / ...).  Fail-closed on $FENCED."""
import os, sys, re
D = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, D)
src = open(f'{D}/grid.py').read(); src = src[:src.index('def main():')]
ns = {'__file__': f'{D}/grid.py'}; exec(src, ns)
FIX = os.environ['FIX']
SWS = ['R11V173_PVELABGEN_OFF']
args = sys.argv[1:]; el = args[:1] == ['--el']; args = args[1:] if el else args
for case in args:
    case = os.path.abspath(case)
    if any(re.search(rf'\b{re.escape(n)}\b', case) for n in ns['FENCED']): print('FENCED-SKIP', case); continue
    w = ns['wdir'](case, el); rel = w.split(ns['GW'] + '/')[1]
    ns['run'](case, 'on', [], el)
    ns['run'](case, 'fix', [], el, FIX)
    ns['run'](case, 'fixoff', ['R11V173_OFF=1'], el, FIX)
    moved = []
    for s in SWS:
        ns['run'](case, 'fx_' + s, [s + '=1'], el, FIX)
        if ns['md5'](f'{w}/fx_{s}.uhdm') != ns['md5'](f'{w}/fix.uhdm'): moved.append(s.split('_')[1])
    g = [f'{w}/{x}/golden.uhdm' for x in os.listdir(w) if x.startswith('gold_') and os.path.exists(f'{w}/{x}/golden.uhdm')]
    if not g: print('FIXRESULT', rel, 'NOGOLD'); continue
    v, det = ns['score'](w, 'fix', 'on', g[0])
    same = ns['md5'](f'{w}/fixoff.uhdm') == ns['md5'](f'{w}/on.uhdm')
    last = open(f'{w}/fix.strict').read().splitlines()[-1] if os.path.exists(f'{w}/fix.strict') else '-'
    print('FIXRESULT', rel, v, f'fixoff==HEAD:{"YES" if same else "NO"}', 'switches:' + (','.join(moved) or '-'), '| fix:', last, '|', det, flush=True)
