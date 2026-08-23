# r10v77 VERIFIER 3-way scorer.  KEY = identity fields only; PAYLOAD = the
# judge-visible fields (no span).  SPAN presence is scored SEPARATELY.
# DEDUPED sets (a def cell and an elab cell share a key in the elab view).
import sys, collections
KIDX = {"port": (0,1,2,3), "sig": (0,1,2)}
def load(p, kind):
    d = collections.defaultdict(set); sp = collections.defaultdict(set)
    for ln in open(p):
        f = ln.rstrip("\n").split("|")
        k = "|".join(f[i] for i in KIDX[kind])
        n = len(KIDX[kind])
        d[k].add("|".join(f[n:-1]))     # judge payload, span column dropped
        sp[k].add(f[-1])                # span presence only
    return d, sp
kind = sys.argv[1]
(g,gs),(o,os_),(q,qs) = (load(p, kind) for p in sys.argv[2:5])
def score(g,o,q,label):
    b = collections.Counter(); rows=[]
    for k in set(g)|set(o)|set(q):
        G,O,Q = g.get(k,set()), o.get(k,set()), q.get(k,set())
        if not G:
            b["NOGOLD-MOVED" if O!=Q else "NOGOLD-SAME"] += 1
            if O!=Q: rows.append(("NOGOLD-MOVED",k,O,Q,G))
            continue
        if O==G and Q==G: b["SAME"]+=1
        elif O!=G and Q==G: b["TO-GOLDEN"]+=1; rows.append(("TO-GOLDEN",k,O,Q,G))
        elif O==G and Q!=G: b["AWAY-GOLDEN"]+=1; rows.append(("AWAY-GOLDEN",k,O,Q,G))
        elif O==Q: b["STILL-WRONG"]+=1; rows.append(("STILL-WRONG",k,O,Q,G))
        else: b["MOVED-WRONG"]+=1; rows.append(("MOVED-WRONG",k,O,Q,G))
    print("[%s] " % label + "  ".join("%s=%d" % (x,b[x]) for x in
        ("TO-GOLDEN","AWAY-GOLDEN","MOVED-WRONG","STILL-WRONG","NOGOLD-MOVED","NOGOLD-SAME","SAME")))
    return rows
rows = score(g,o,q,"JUDGE-FIELDS")
score(gs,os_,qs,"SPAN-PRESENCE")
if len(sys.argv) > 5:
    for r in sorted(rows):
        if r[0] in ("STILL-WRONG",) and len(sys.argv) < 7: continue
        print("  %-13s %s\n      pris=%s\n      patc=%s\n      gold=%s" % (r[0], r[1], sorted(r[2]), sorted(r[3]), sorted(r[4])))
