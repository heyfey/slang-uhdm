#!/usr/bin/env python3
# msdist.py <run dir> <tag>...: multiset distance to golden (missing, extra), headers dropped
import sys, collections
d=sys.argv[1]
def ms(f): return collections.Counter(open(f).read().splitlines()[1:])
g=ms(d+'/sl.dump')
out=[]
for t in sys.argv[2:]:
    o=ms(d+'/'+t+'.dump'); out.append(f'{t}=-{sum((g-o).values())}/+{sum((o-g).values())}')
print(d.split('_cases/')[-1].split('/cases/')[-1], ' '.join(out))
