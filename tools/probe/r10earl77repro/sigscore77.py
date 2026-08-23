# r10earl77 -- 3-way scorer over the WHOLE-SIGNAL census (sig77): KEY = owner
# kind | owner fullname | signal name; PAYLOAD = container + object kind.
# A port-keyed census is blind to a BODY signal that moves; this one is not.
import sys, collections
def load(p):
    d = collections.defaultdict(set)
    for ln in open(p):
        f = ln.rstrip("\n").split("|")
        d["|".join(f[:3])].add(f[3] + "|" + f[4])
    return d
g, o, q = (load(p) for p in sys.argv[1:4])
b = collections.Counter(); rows = []
for k in set(g) | set(o) | set(q):
    G, O, Q = g.get(k, set()), o.get(k, set()), q.get(k, set())
    if not G:
        b["NOGOLD-MOVED" if O != Q else "NOGOLD-SAME"] += 1
        if O != Q: rows.append(("NOGOLD-MOVED", k, O, Q, G))
        continue
    if O == G and Q == G: b["SAME"] += 1
    elif O != G and Q == G: b["TO-GOLDEN"] += 1; rows.append(("TO-GOLDEN", k, O, Q, G))
    elif O == G and Q != G: b["AWAY-GOLDEN"] += 1; rows.append(("AWAY-GOLDEN", k, O, Q, G))
    elif O == Q: b["STILL-WRONG"] += 1
    else: b["MOVED-WRONG"] += 1; rows.append(("MOVED-WRONG", k, O, Q, G))
for k in ("TO-GOLDEN","AWAY-GOLDEN","MOVED-WRONG","STILL-WRONG","NOGOLD-MOVED","NOGOLD-SAME","SAME"):
    print("%-14s %d" % (k, b[k]))
if len(sys.argv) > 4:
    for r in sorted(rows):
        print("  %-13s %s pris=%s patc=%s gold=%s" % (r[0], r[1], sorted(r[2]), sorted(r[3]), sorted(r[4])))
