import sys, collections
def load(f): return collections.Counter(l.rstrip('\n') for l in open(f))
g=load(sys.argv[1])
for f in sys.argv[2:]:
    x=load(f); d=sum(((g-x)+(x-g)).values()); print(f, "distance", d)
