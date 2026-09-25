import sys,os
# recdiff.py <GW> <case> <tagA> <tagB>: records differing from golden under A and B (walk-aligned lines)
gw,c,ta,tb=sys.argv[1:5]
def load(t):
    a=open(f'{gw}/{c}/{t}.a.txt').read().splitlines(); b=open(f'{gw}/{c}/{t}.b.txt').read().splitlines()
    return a,b
def diffs(t):
    a,b=load(t)
    return {(i,x,y) for i,(x,y) in enumerate(zip(a,b)) if x!=y}, len(a), len(b)
da,la,lb=diffs(ta); db,la2,lb2=diffs(tb)
sa={(i,y) for i,x,y in da}; sb={(i,y) for i,x,y in db}
print(f'{c}: {ta} {len(da)} diff (objs {la}/{lb}), {tb} {len(db)} diff (objs {la2}/{lb2}); leave {len({i for i,_ in sa}-{i for i,_ in sb})} enter {len({i for i,_ in sb}-{i for i,_ in sa})} changed {len({i for i,_ in sb}&{i for i,_ in sa})-len(sa&sb)}')
if len(sys.argv)>5:
    A,_=load(tb)
    for i,x,y in sorted(db)[:int(sys.argv[5])]: print('  G',x,'\n  O',y)
