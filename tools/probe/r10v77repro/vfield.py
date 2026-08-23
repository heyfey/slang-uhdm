# r10v77 -- FIELD-BY-FIELD adjudication of every cell whose payload changed.
# For each key where pris != patched, split the payload into fields and report,
# per field: pris value, patched value, golden value, and the verdict.
import sys, collections, re
KIDX = {"port": 4, "sig": 3}
def load(p, kind):
    n = KIDX[kind]; d = {}
    for ln in open(p):
        f = ln.rstrip("\n").split("|")
        d.setdefault("|".join(f[:n]), []).append(f[n:-1])
    return d
kind = sys.argv[1]
g,o,q = (load(p,kind) for p in sys.argv[2:5])
bad = collections.Counter()
for k in sorted(set(o)|set(q)):
    O,Q = sorted(map(tuple,o.get(k,[]))), sorted(map(tuple,q.get(k,[])))
    if O == Q: continue
    G = sorted(map(tuple,g.get(k,[])))
    Gs = set(map(tuple,G))
    for a,b in zip(O,Q):
        for i,(x,y) in enumerate(zip(a,b)):
            if x == y: continue
            gv = sorted({t[i] for t in G}) if G else ["<nogold>"]
            verdict = "TO-GOLDEN" if [y]==gv else ("AWAY-GOLDEN" if [x]==gv else "BOTH-WRONG")
            bad[verdict] += 1
            print("%-11s %s  field[%d]\n    pris=%s\n    patc=%s\n    gold=%s" % (verdict,k,i,x,y,gv))
print("FIELD VERDICTS:", dict(bad))
