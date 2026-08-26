#!/usr/bin/env python3
"""r10uvm154 — name, BY (mode,test), every corpus cell holding an enum_const
whose written initializer is the UNARY MINUS this pass's law governs.

MEASUREMENT ONLY.  Run on the PRISTINE census TSV to PREDICT the mover set by
name before any patched sweep exists (RESUME.md §6/§7), and on the patched one
to confirm it.  Prints one line per (mode,test) with the per-view payloads.
"""
import sys, collections
name = sys.argv[2] if len(sys.argv) > 2 else "UVM_CVR_ALL"
rows = collections.defaultdict(list)
for line in open(sys.argv[1], errors="replace"):
    f = line.rstrip("\n").split("\t")
    if len(f) != 4 or not f[3].startswith("EC|"): continue
    p = f[3].split("|")
    if len(p) < 9 or p[2] != name: continue
    rows[(f[0], f[1])].append((f[2], p[4], p[5], p[6]))
ok = bad = 0
for k in sorted(rows):
    g = sorted(x for x in rows[k] if x[0] == "G")
    o = sorted(x for x in rows[k] if x[0] == "O")
    verdict = "AGREE" if [x[1:] for x in g] == [x[1:] for x in o] else "DIFFER"
    if not o: verdict = "NO-OURS"
    if verdict == "AGREE": ok += 1
    elif verdict == "DIFFER": bad += 1
    print("%-9s %-34s %-7s G=%s O=%s" % (k[0], k[1], verdict,
          [x[1:] for x in g], [x[1:] for x in o]))
print("CELLS agree=%d differ=%d" % (ok, bad))
