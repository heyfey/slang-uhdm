#!/usr/bin/env python3
# r11u210: order-blind AWAY census of one case (.v dir): records (depth dropped) as multisets.
# LOST = in golden AND pristine, not in law; GAINED = in golden AND law, not in pristine. dist = ours-not-in-golden.
import sys, subprocess, collections, os
SC=os.environ.get('SCMP','/tmp/r11u210_bin/uhdm-strictcmp')
def recs(g, o, tag, wd):
    a=f'{wd}/{tag}.fa'; b=f'{wd}/{tag}.fb'
    subprocess.run([SC,'--max','0','--dump-a',a,'--dump-b',b,g,o],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    ld=lambda f: collections.Counter('\t'.join(l.rstrip('\n').split('\t')[1:]) for l in open(f)) if os.path.exists(f) else collections.Counter()
    return ld(a), ld(b)
g, p, l, wd = sys.argv[1:5]
G, P = recs(g, p, 'p', wd); _, L = recs(g, l, 'l', wd)
lost = (G & P) - L; gained = (G & L) - P
dp = sum((P - G).values()); dl = sum((L - G).values())
print(f'dist {dp} -> {dl} lost={sum(lost.values())} gained={sum(gained.values())}')
if len(sys.argv) > 5:
    for k,v in lost.items(): print('  LOST', v, k)
    for k,v in gained.items(): print('  GAIN', v, k)
