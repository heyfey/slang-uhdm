#!/usr/bin/env python3
"""r10uvm148 — A-PRIORI MOVER PREDICTOR.  MEASUREMENT ONLY.

  pred148.py <pristine.cen> [<pristine.cen> ...]

Reads ONLY the PRISTINE census (never golden, never the patched database) and
names the cells § tfItemLocalLosesToPkgVar148 can move:

  PREDICTED-CELLS   a TF-ITEM body local (PROD=TFITEM, LOC=FUNC) of a
                    subroutine whose home PACKAGE lists a variable of the same
                    name (PKGV=1), whose reference is BOUND to that local
                    (BSK=function|task).  The law replaces that binding with
                    the package variable — unless `condPredEarlyBound81` says
                    the reference was bound EARLY, which is a SYNTAX test the
                    database cannot answer; so this count is an UPPER BOUND and
                    the set it names is a SUPERSET of the true movers.

  PREDICTED-FORK    the `ParallelBlockStatement` half: a reference with a
                    fork_stmt / named_fork between it and its subroutine
                    (FORK=1) that is bound to a local or formal of a
                    package-scope subroutine.  Only a reference inside a
                    CONDITIONAL PREDICATE can actually move, which again the
                    database cannot say — an upper bound.

  PREDICTED-DBS     the distinct DB= tags that carry at least one such cell.

A database with NEITHER count nonzero must not move a byte.
"""
import sys, collections

cells = []
forks = []
dbs = collections.Counter()
for path in sys.argv[1:]:
    try:
        fh = open(path)
    except FileNotFoundError:
        continue
    for ln in fh:
        ln = ln.rstrip("\n")
        if "ROW=REF" not in ln:
            continue
        d = {}
        for f in ln.split("|"):
            if "=" in f:
                k, v = f.split("=", 1)
                d[k] = v
        db = d.get("DB", path)
        bound_local = d.get("BSK") in ("function", "task")
        if (d.get("PROD") == "TFITEM" and d.get("LOC") == "FUNC"
                and d.get("PKGV") == "1" and bound_local):
            cells.append((db, d))
            dbs[db] += 1
        if (d.get("FORK") == "1" and d.get("PKGV") == "1" and bound_local):
            forks.append((db, d))
            dbs[db] += 1

for db, d in cells:
    print("CELL   %s %s %s %s/%s role=%s -> %s"
          % (db, d.get("HNAME"), d.get("RSPAN"), d.get("PROD"), d.get("LOC"),
             d.get("ROLE"), d.get("BOWN")))
for db, d in forks:
    print("FORK   %s %s %s %s/%s role=%s -> %s"
          % (db, d.get("HNAME"), d.get("RSPAN"), d.get("PROD"), d.get("LOC"),
             d.get("ROLE"), d.get("BOWN")))
print("PREDICTED-CELLS=%d PREDICTED-FORK=%d PREDICTED-DBS=%d"
      % (len(cells), len(forks), len(dbs)))
for db in sorted(dbs):
    print("  DB %s cells=%d" % (db, dbs[db]))
