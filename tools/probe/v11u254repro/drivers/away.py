#!/usr/bin/env python3
# (v11u254: copied from r11u254repro/drivers)
# (r11u254: copied from r11u255repro/drivers)
# (r11u255: copied from r11u253repro/drivers)
# (r11u253: copied from r11u251repro/drivers)
# (r11u251: copied from v11u202repro/drivers; SCMP = the strictcmp binary, export it)
# v11u202: order-blind AWAY census of one case (.v dir): records (depth dropped) as multisets.
# LOST = in golden AND pristine, not in law; GAINED = in golden AND law, not in pristine. dist = ours-not-in-golden.
import sys, subprocess, collections, os
SC=os.environ['SCMP']
def recs(g, o, tag, wd):
    a=f'{wd}/{tag}.fa'; b=f'{wd}/{tag}.fb'
    subprocess.run([SC,'--max','0','--dump-a',a,'--dump-b',b,g,o],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    ld=lambda f: collections.Counter('\t'.join(l.rstrip('\n').split('\t')[1:]) for l in open(f)) if os.path.exists(f) else collections.Counter()
    return ld(a), ld(b)
g, p, l, wd = sys.argv[1:5]
# r11u255: fail-closed fence check on every path argument (word boundary on the names of $FENCED).
import re
_fz = os.environ.get('FENCED', '').split()
if len(_fz) != 4: sys.exit('away.py: FENCED unset, refusing')
_fr = re.compile(r'(?<![A-Za-z0-9_])(?:%s)(?![A-Za-z0-9_])' % '|'.join(map(re.escape, _fz)))
if any(_fr.search(a) for a in (g, p, l, wd)): sys.exit('away.py: fenced path refused')
G, P = recs(g, p, 'p', wd); _, L = recs(g, l, 'l', wd)
lost = (G & P) - L; gained = (G & L) - P
dp = sum((P - G).values()); dl = sum((L - G).values())
print(f'dist {dp} -> {dl} lost={sum(lost.values())} gained={sum(gained.values())}')
if len(sys.argv) > 5:
    for k,v in lost.items(): print('  LOST', v, k)
    for k,v in gained.items(): print('  GAIN', v, k)
