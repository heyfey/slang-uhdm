# r10earl77 -- 3-way scorer: golden vs PRISTINE vs PATCHED over the cen77 grid.
# KEY   = the CELL IDENTITY (module def | port name | direction | instance).
# PAYLOAD = everything the law can move: the backing object's CONTAINER+KIND
#           and the port's Low_conn target.  RESUME §9: a payload field left in
#           the KEY makes a moved cell look like two half-cells (a phantom
#           NOGOLD-MOVED / AWAY-GOLDEN pair) -- keep the key to identity alone.
# DEDUPED (presence, not multiplicity): the --elabuhdm view lists a def cell and
# an elab cell at the same key (earl75 R3, pre-existing on BOTH binaries), and a
# multiplicity-scored join reports that pre-existing duplication as this law's
# MOVED-WRONG.
import sys, collections
def load(p):
    d = collections.defaultdict(set)
    for ln in open(p):
        f = ln.rstrip("\n").split("|")
        d["|".join([f[0], f[1], f[2], f[-1]])].add(f[4] + "|" + f[5])
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
    elif O == Q: b["STILL-WRONG"] += 1; rows.append(("STILL-WRONG", k, O, Q, G))
    else: b["MOVED-WRONG"] += 1; rows.append(("MOVED-WRONG", k, O, Q, G))
for k in ("TO-GOLDEN","AWAY-GOLDEN","MOVED-WRONG","STILL-WRONG","NOGOLD-MOVED","NOGOLD-SAME","SAME"):
    print("%-14s %d" % (k, b[k]))
if len(sys.argv) > 4:
    for r in sorted(rows):
        print("  %-13s %s\n      pris=%s\n      patc=%s\n      gold=%s" %
              (r[0], r[1], sorted(r[2]), sorted(r[3]), sorted(r[4])))
