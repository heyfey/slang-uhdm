#!/usr/bin/env python3
# overlap.py <run dir> <tag>...: golden line overlap, header lines dropped
import sys, collections
d=sys.argv[1]
def ms(f):
    try: L=open(f).read().splitlines()
    except FileNotFoundError: return None
    return collections.Counter(l for l in L if not l.endswith('.uhdm') and 'Restored design' not in l)
g=ms(d+'/sl.dump')
print(d.split('_cases/')[-1].split('/cases/')[-1], 'golden', sum(g.values()), ' '.join(f'{t}={sum(min(c,o[k]) for k,c in g.items()) if (o:=ms(d+"/"+t+".dump")) is not None else "NA"}' for t in sys.argv[2:]))
