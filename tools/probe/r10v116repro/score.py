import sys, collections
def cnt(p):
    c=collections.Counter()
    with open(p, errors='replace') as f:
        for l in f: c[l]+=1
    return c
g,a,b=[cnt(x) for x in sys.argv[1:4]]
lost_bad=lost_good=gain_bad=gain_good=0
for l in set(a)|set(b):
    ca,cb,cg=a.get(l,0),b.get(l,0),g.get(l,0)
    if ca>cb:
        d=ca-cb
        # occurrences removed: excess ones first
        excess=max(0,ca-cg)
        lost_good+=min(d,excess); lost_bad+=d-min(d,excess)
    elif cb>ca:
        d=cb-ca
        deficit=max(0,cg-ca)
        gain_good+=min(d,deficit); gain_bad+=d-min(d,deficit)
print(f"TO-GOLDEN: removed-excess={lost_good} added-missing={gain_good}   AWAY: lost-correct={lost_bad} added-wrong={gain_bad}")
