#!/usr/bin/env python3
"""predcheck.py: the committed predictions of passes 196 and 198 against the movers measured here.  A database of the
HEAD sweep (swH) is a pass-N mover when the sweep with that landing switched off (sw6: R11U196_OFF R11V196_OFF; sw8:
R11U198_OFF) writes other bytes.  Prints, per pass, movers inside / outside the committed prediction file and the
predicted databases that do not move.  Fenced corpus rows are skipped unread (fail-closed on $FENCED)."""
import os, re, glob, hashlib, sys
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('predcheck.py: source drivers/env.sh first')
R = os.environ['R204_ROOT']
def fenced(p): return any(re.search(rf'\b{re.escape(f)}\b', p) for f in F)
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except FileNotFoundError: return None
def movers(off):
    out = set()
    for p in glob.glob('/tmp/r11u204_swH/probe/*.uhdm'):
        b = os.path.basename(p)
        if md5(p) != md5(f'{off}/probe/{b}'): out.add('probe/' + b[:-5].replace('__', '/'))
    for c in ('surelog', 'uhdm2rtlil'):
        for d in glob.glob(f'/tmp/r11u204_swH/{c}/*/*/slang.uhdm'):
            rel = os.path.relpath(d, '/tmp/r11u204_swH')
            if fenced(rel): continue
            if md5(d) != md5(f'{off}/{rel}'): out.add(re.sub(r'-[0-9a-f]+/slang\.uhdm$', '', rel))
    return out
def pred(path, sep):
    s = set()
    for l in open(path):
        k = l.split()[0] if l.strip() else ''
        if not k or k.startswith(('ROWS', '#')): continue
        if k.startswith('probe/'): k = 'probe/' + k[6:].replace('__', '/')
        if k.startswith('downstream/'): continue
        s.add(k)
    return s
for n, off, pf in ((196, '/tmp/r11u204_sw6', f'{R}/tools/probe/r11u196repro/evidence/predict_census_before_sweep.txt'),
                   (198, '/tmp/r11u204_sw8', f'{R}/tools/probe/r11u198repro/evidence/census/predicted_movers.txt')):
    M = movers(off); P = pred(pf, None)
    mp = sorted(k for k in M if k.startswith('probe/')); mc = sorted(k for k in M if not k.startswith('probe/'))
    print(f'pass {n}: movers at HEAD {len(M)} (probe {len(mp)}, corpus {len(mc)}); committed prediction {len(P)} databases')
    print(f'  movers outside the prediction: {len(M - P)} ' + ' '.join(sorted(M - P)))
    print(f'  predicted, not moved: {len(P - M)} ' + ' '.join(sorted(P - M)))
