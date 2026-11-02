import sys,collections,re
def ms(f):
    c=collections.Counter()
    for l in open(f):
        l=l.strip()
        if 'Restored design' in l: continue
        c[l]+=1
    return c
g=ms(sys.argv[1])
for f in sys.argv[2:]:
    o=ms(f); ov=sum(min(v,o[k]) for k,v in g.items())
    print(f.split('/')[-1], 'overlap', ov, 'of golden', sum(g.values()), 'ours', sum(o.values()))
