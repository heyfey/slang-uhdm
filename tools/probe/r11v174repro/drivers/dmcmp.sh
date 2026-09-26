#!/bin/bash
# dmcmp <griddir>: uhdm-dump line multisets (ids stripped): golden vs pris vs law
source $(dirname $0)/env.sh
d=$1
for t in gold/golden pris law; do [ -s $d/$t.uhdm ] && $UHDM_DUMP $d/$t.uhdm 2>/dev/null | sed -E 's/id:[0-9]+,? ?//g; s#file:[^,]*/##' > $d/$(basename $t).dm; done
python3 - $d <<'P'
import sys
from collections import Counter
d=sys.argv[1]
def ld(t):
    try: return Counter(open(f'{d}/{t}.dm').read().split('\n'))
    except: return Counter()
G,P,L=ld('golden'),ld('pris'),ld('law')
lost=(P&G)-(L&G)   # golden-agreeing lines pris had and law lost
newaway=(L-G)-(P-G)
print(f"{d} away {sum((P-G).values())}->{sum((L-G).values())} missing {sum((G-P).values())}->{sum((G-L).values())} lostGolden={sum(lost.values())} newAway={sum(newaway.values())}")
if len(sys.argv)>0:
    for l,n in list(lost.items())[:6]: print('   LOST',n,l.strip()[:150])
    for l,n in list(newaway.items())[:6]: print('   NEWAWAY',n,l.strip()[:150])
P
