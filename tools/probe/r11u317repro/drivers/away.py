#!/usr/bin/env python3
# (r11u317: copied from v11u315repro/drivers)
# (r11u315: copied from r11u313repro/drivers)
# (r11u313: copied from v11u311repro/drivers)
# (v11u311: copied from r11u311repro/drivers)
# (r11u311: copied from r11u309repro/drivers)
# (r11u309: copied from r11u307repro/drivers)
# (r11u307: copied from r11u305repro/drivers)
# (r11u305: copied from r11u303repro/drivers)
# (r11u303: copied from r11u301repro/drivers)
# (r11u299: copied from r11u297repro/drivers)
# (r11u297: copied from r11u295repro/drivers)
# (r11u295: copied from r11u293repro/drivers)
# (r11u293: copied from r11u291repro/drivers)
# (r11u291: copied from r11u289repro/drivers)
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
# (r11u259: copied from r11u257repro/drivers)
# (r11u257: copied from r11u255repro/drivers)
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
