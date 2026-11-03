#!/usr/bin/env python3
# overlap.py <run dir> <tagA> <tagB>: golden line-overlap (sum over golden dump lines of min(golden count, ours count)), path-normalized dumps
import sys, collections
d=sys.argv[1]
def ms(f):
    try: return collections.Counter(l.rstrip('\n') for l in open(f) if not l.startswith(('surelog.uhdm','pris.uhdm')) and 'Restored design' not in l)
    except FileNotFoundError: return None
g=ms(d+'/sl.dump')
out=[]
for t in sys.argv[2:]:
    o=ms(d+'/'+t+'.dump')
    out.append(str(sum(min(c,o[k]) for k,c in g.items())) if o is not None else 'NA')
print(d.split('/cases/')[-1], 'golden', sum(g.values()), ' '.join(f'{t}={v}' for t,v in zip(sys.argv[2:],out)))
