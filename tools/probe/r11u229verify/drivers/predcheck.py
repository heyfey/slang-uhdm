#!/usr/bin/env python3
# (r11u229: copied from r11u226verify/drivers/predcheck.py.)
"""predcheck.py <L> <off wd> <prediction file>...: the byte movers between the HEAD sweep L and one landing's
off sweep (probe, surelog and uhdm2rtlil databases; fenced corpus paths skipped unread by word boundary), named in the
predictions' format (probe/<case>, surelog/<mode>/<test>, uhdm2rtlil/<mode>/<test>), against the union of the given
frozen predictions: predicted and moved, moved unpredicted, predicted unmoved.  Fail-closed on $FENCED."""
import os, re, sys, glob, hashlib
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('predcheck.py: source drivers/env.sh first')
L, O = sys.argv[1:3]
def fenced(p): return any(re.search(rf'\b{re.escape(f)}\b', p) for f in F)
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except FileNotFoundError: return None
moved = set()
for p in glob.glob(f'{L}/probe/*.uhdm'):
    r = os.path.relpath(p, L)
    if md5(p) != md5(f'{O}/{r}'): moved.add('probe/' + os.path.basename(p)[:-5].replace('__', '/'))
for c in ('surelog', 'uhdm2rtlil'):
    for p in glob.glob(f'{L}/{c}/*/*/slang.uhdm'):
        r = os.path.relpath(p, L)
        if fenced(r): continue
        if md5(p) != md5(f'{O}/{r}'):
            mode, t = r.split('/')[1], re.sub(r'-[0-9a-f]+$', '', r.split('/')[2])
            moved.add(f'{c}/{mode}/{t}')
pred = set()
for f in sys.argv[3:]:
    for l in open(f):
        w = l.split()
        if w and '/' in w[0] and not w[0].startswith('#'): pred.add(w[0])
print(f'moved {len(moved)} predicted {len(pred)} both {len(moved & pred)}')
for x in sorted(moved - pred): print('  MOVED-UNPREDICTED', x)
for x in sorted(pred - moved): print('  PREDICTED-UNMOVED', x)
