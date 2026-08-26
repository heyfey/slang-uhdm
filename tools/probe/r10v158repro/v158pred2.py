import sys, collections
def load(p):
    m = collections.defaultdict(set)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 13 or f[1] != "BLK": continue
        m[(f[5], f[6])].add((f[7], f[8], int(f[9]), f[11], f[12]))
    return m
g = load(sys.argv[1]); o = load(sys.argv[2]); tag = sys.argv[3]
for k in sorted(set(g) & set(o)):
    gmax = max(v[2] for v in g[k]); omax = max(v[2] for v in o[k])
    if gmax > 0 and omax == -1:
        print("TOWARD\t%s\t%s\t%s\tG=%s\tO=%s" % (tag, k[0], k[1], sorted(g[k]), sorted(o[k])))
    if omax > 0 and gmax == -1:
        print("AWAY\t%s\t%s\t%s\tG=%s\tO=%s" % (tag, k[0], k[1], sorted(g[k]), sorted(o[k])))
    # name half of the law: golden names the block, we do not
    gn = set(v[1] for v in g[k] if v[1] != '-'); on = set(v[1] for v in o[k] if v[1] != '-')
    if gn and not on:
        print("NAME\t%s\t%s\t%s\tG=%s\tO=%s" % (tag, k[0], k[1], sorted(g[k]), sorted(o[k])))
