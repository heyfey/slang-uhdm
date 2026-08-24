import sys, collections
def cnt(p):
    c=collections.Counter()
    with open(p, errors='replace') as f:
        for l in f: c[l]+=1
    return c
g,a,b=[cnt(x) for x in sys.argv[1:4]]
print("--- LOST-CORRECT (patch removed a line we had at/below golden count) ---")
for l in sorted(set(a)|set(b)):
    ca,cb,cg=a.get(l,0),b.get(l,0),g.get(l,0)
    if ca>cb:
        d=ca-cb; excess=max(0,ca-cg); bad=d-min(d,excess)
        if bad: print(f"  x{bad} (g={cg} a={ca} b={cb}) {l.rstrip()[:150]}")
print("--- ADDED-WRONG (patch added a line beyond golden count) ---")
for l in sorted(set(a)|set(b)):
    ca,cb,cg=a.get(l,0),b.get(l,0),g.get(l,0)
    if cb>ca:
        d=cb-ca; deficit=max(0,cg-ca); bad=d-min(d,deficit)
        if bad: print(f"  x{bad} (g={cg} a={ca} b={cb}) {l.rstrip()[:150]}")
