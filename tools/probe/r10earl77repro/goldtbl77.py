# r10earl77 -- the GOLDEN TABLE for the port-kind grid: one row per (port,
# direction), showing golden's kind, the pristine binary's and the patched
# binary's, read off the cen77 censuses of one arm directory.
import sys, collections
d = sys.argv[1]
def load(p):
    m = {}
    for ln in open(p):
        f = ln.rstrip("\n").split("|")
        if not f[-1].startswith("INST=work@top"): continue     # elaborated only
        m[(f[0][4:], f[1][5:], f[2][4:], f[-1][5:])] = (f[3][3:], f[4][5:])
    return m
g, o, q = (load("%s/%s.cen" % (d, t)) for t in ("g", "o", "q"))
keys = sorted(set(g) | set(o) | set(q), key=lambda k: (k[1], k[2]))
seen = set()
print("%-14s %-6s %-30s %-22s %-22s %-22s %s" % ("PORT","DIR","TYPESPEC","GOLDEN","PRISTINE","PATCHED","VERDICT"))
for k in keys:
    if (k[1], k[2]) in seen: continue
    seen.add((k[1], k[2]))
    G, O, Q = g.get(k), o.get(k), q.get(k)
    v = "same" if (G and Q and G[1] == Q[1]) else "DIFFERS"
    if G and O and Q and O[1] != G[1] and Q[1] == G[1]: v = "TO-GOLDEN"
    print("%-14s %-6s %-30s %-22s %-22s %-22s %s" % (
        k[1], k[2], (G or Q or O)[0], (G or ("-","-"))[1], (O or ("-","-"))[1],
        (Q or ("-","-"))[1], v))
