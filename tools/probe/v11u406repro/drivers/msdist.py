import sys, collections
def load(p):
    return collections.Counter(open(p, errors='replace').read().split('\n'))
g = load(sys.argv[1])
for p in sys.argv[2:]:
    s = load(p)
    print(p, sum(((g - s) + (s - g)).values()))
