#!/usr/bin/env python3
"""vbuvm9 — the COMPLETE blast radius: every typespec whose vpiInstance VIEW
differs between the pristine and the patched database, with golden's value
beside it.  Key = kind|name|loc only (no listing filter, no chain), so nothing
is dropped for being anonymous, unlisted, or differently parented."""
import subprocess, sys, collections
CEN = __import__("os").environ.get("CEN", "/tmp/vbuvm9_cen")
def rows(db, tag):
    out = subprocess.run([CEN, db, tag], capture_output=True, text=True).stdout
    d = collections.defaultdict(list)
    for ln in out.splitlines():
        if not ln.startswith("TS "):
            continue
        f = ln.split()
        iv = next((x[9:] for x in f[5:] if x.startswith("instview=")), None)
        d[(f[2], f[3], f[4])].append(iv)
    return {k: ",".join(sorted(v)) for k, v in d.items()}
g, p, q = (rows(sys.argv[i], t) for i, t in ((1, "G"), (2, "P"), (3, "Q")))
n = collections.Counter()
for k in sorted(set(p) | set(q)):
    P, Q = p.get(k, "MISSING"), q.get(k, "MISSING")
    if P == Q:
        continue
    G = g.get(k, "MISSING")
    v = ("CONVERTED" if G == Q and G != P else
         "OVER-FIRE" if G == P and G != Q else
         "NO-GOLDEN-KEY" if G == "MISSING" else "MOVED-STILL-WRONG")
    n[v] += 1
    print("%-18s %s|%s|%s  G=%s P=%s Q=%s" % (v, *k, G, P, Q))
print("-- changed typespec keys: " + " ".join("%s=%d" % kv for kv in sorted(n.items())))
