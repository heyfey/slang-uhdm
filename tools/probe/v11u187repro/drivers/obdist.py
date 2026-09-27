import sys, collections
def load(p):
    c = collections.Counter()
    try:
        for l in open(p, errors='replace'):
            c[l.rstrip('\n')] += 1
    except FileNotFoundError:
        return None
    return c
a, b = load(sys.argv[1]), load(sys.argv[2])
if a is None or b is None:
    print('NA'); sys.exit()
print(sum(((a - b) + (b - a)).values()))
