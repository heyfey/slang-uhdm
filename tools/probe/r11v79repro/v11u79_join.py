#!/usr/bin/env python3
"""v11u79 ROW JOIN — key (name, mode), compare status + dump, BOTH modes.
A multiset-safe join: a duplicate key is an error, not a silent last-writer."""
import csv, sys
def load(fn, modes=None):
    d = {}
    for r in csv.DictReader(open(fn)):
        if modes and r["mode"] not in modes: continue
        k = (r["name"], r["mode"])
        if k in d: sys.exit(f"DUPLICATE KEY {k} in {fn}")
        d[k] = (r["status"], r.get("dump", ""))
    return d
base, fresh = sys.argv[1], sys.argv[2]
b = load(base); f = load(fresh)
common = set(b) & set(f)
diff = [k for k in sorted(common) if b[k] != f[k]]
print(f"base={len(b)} fresh={len(f)} common={len(common)} "
      f"only_base={len(set(b)-set(f))} only_fresh={len(set(f)-set(b))} DIFFER={len(diff)}")
for k in diff:
    print(f"  {k[0]:<42} {k[1]:<10} base={b[k]}  fresh={f[k]}")
print("PASS" if not diff and not (set(b)-set(f)) and not (set(f)-set(b)) else "ATTENTION")
