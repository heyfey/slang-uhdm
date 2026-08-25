#!/usr/bin/env python3
"""r10uvm145 — THE A-PRIORI MOVER PREDICTION, read off the PRISTINE databases
alone.  MEASUREMENT ONLY.

  pred145.py <cen-file> ...            (one .cen per database, named <db>.cen)

A subroutine is a TF-ITEM body when its locals are listed on the `task_func`
and NOT on the body `begin` (`NVARS>0 && BVARS==-1` — Surelog's own production
signature, and ours: § blockItems9's block shape dual-lists them).  Rows are
joined to their owner by HID, the task_func's UhdmId: HSPAN is NOT unique (a
package listing and a class listing carry the same method at the same span)
and a last-writer dict on HSPAN silently dropped a third of the population the
first time this ran (RESUME.md §9's multiset law).

Two things move under § tfItemLocalInitHoistsNoStatement145, and BOTH are
predicted:

  HOIST      a top-level body assignment of a TF-ITEM body whose Lhs IS a
             `variables` object (SLHSVAR=1) — the statement the law removes.
             That is SURELOG'S OWN test for "this assignment is a declaration"
             (`any_cast<variables*>(stmt->Lhs())`, CompileStmt.cpp:2508).  The
             first cut asked instead whether the Lhs object appears in the
             owner's Variables list (LHOIST=1 && LOWN=func) and UNDER-COUNTED
             in the ELAB view, where a cloned listing's Variables vector holds
             different objects than its body does — the wide boundary gate
             caught it on r10uvm139repro/g139_b_kinds.sv elab.
  WRAPPER    a TF-ITEM body `begin` that survives only because the removed
             statements were counted toward the two-statement threshold:
             #hoists >= 1 and NSTMTS - (#hoists) <= 1.

  CANDIDATE  a TF-ITEM body `begin` with NO hoist and <= 1 statement.  Its
             wrapper exists only if `initCount > 0`, and the one initialiser
             the database CANNOT show is a written `= new` already dropped by
             § declInitWrittenNewNoStmt66 (it leaves neither a statement nor a
             `vpiExpr`).  So a CANDIDATE may or may not move and only the
             SOURCE can say; the count is reported separately and never folded
             into PREDICTED-HOISTS.

`#hoists >= 1` is load-bearing.  The threshold half moves a body only when
`initCount > 0`, and a TF-ITEM body with NO initialised local had `initCount ==
0` before the law and has it after — nothing changes there however few
statements it has.  A first cut of this predictor dropped that conjunct and
named ten extra databases (PackFunc / EvalFunc / FuncIoTypespec /
PreprocFunc / BlockingAssignRewrite, both modes, subroutines `log2`, `fshl_s`,
`foo_bar`); ALL FIVE SOURCES were then read and NONE of their body locals
carries an initialiser — the `begin` those bodies dump is the SOURCE `begin`,
not a wrapper.  They are printed below as NOT-PREDICTED so the distinction is
on the record.

The one thing the pristine database CANNOT show is a TF-ITEM local whose
initialiser was already dropped by § declInitWrittenNewNoStmt66 (a written
`= new`): it leaves neither a statement nor a `vpiExpr`.  Such a body would
lose its wrapper too.  The NOT-PREDICTED list below is exactly the set where
that could hide (a TF-ITEM body begin with no hoist and <= 1 statement), and
reading those five sources closed it empirically at zero.

Prints one line per database with a nonzero count, the named subroutines, then
the totals.
"""
import sys, os, collections

tot = collections.Counter()
per = {}
allnames = collections.Counter()
notpred = collections.Counter()
for p in sys.argv[1:]:
    bodies = {}
    hoist = collections.Counter()
    try:
        rows = open(p).read().splitlines()
    except OSError:
        continue
    for ln in rows:
        if not ln.startswith("ROW="):
            continue
        d = dict(f.split("=", 1) for f in ln.split("|") if "=" in f)
        if d["ROW"] == "BODY":
            bodies[d["HID"]] = d
        elif d["ROW"] == "STMT" and d.get("SLHSVAR") == "1":
            hoist[d["HID"]] += 1
    nh = nw = ncand = 0
    names = collections.Counter()
    for hid, b in bodies.items():
        if b["BKIND"] != "begin":
            continue
        if b["BVARS"] != "-1" or int(b["NVARS"]) <= 0:
            continue                      # not the TF-ITEM signature
        h = hoist.get(hid, 0)
        n = int(b["NSTMTS"])
        nm = b.get("HSCOPE", "-") + "/" + b.get("HNAME", "-")
        if h == 0:
            if n <= 1:
                notpred[nm] += 1          # § 66 could hide here: read the source
                tot["candidates"] += 1
                ncand += 1
            continue                      # nothing to remove, wrapper stays
        nh += h
        tag = ""
        if n - h <= 1:
            nw += 1
            tag = " WRAPPER"
        names[nm + tag] += 1
    if nh or nw or ncand:
        per[p] = (nh, nw, names)
        allnames.update(names)
        tot["dbs"] += 1
        tot["hoists"] += nh
        tot["wrappers"] += nw
for p in sorted(per, key=lambda x: (-per[x][0], -per[x][1])):
    nh, nw, names = per[p]
    print("%-62s hoists=%d wrappers=%d" % (os.path.basename(p)[:-4], nh, nw))
    for k, v in sorted(names.items()):
        print("        %3d %s" % (v, k))
print("-- SUBROUTINES NAMED ACROSS ALL DATABASES:")
for k, v in sorted(allnames.items()):
    print("   %4d %s" % (v, k))
print("-- CANDIDATES (TF-ITEM body begin, no hoist, <=1 statement: the only")
print("   place a § declInitWrittenNewNoStmt66 drop could hide an initialiser;")
print("   in the CORPUS every source below was read and carries NO initialised")
print("   local, so none of them moves):")
for k, v in sorted(notpred.items()):
    print("   %4d %s" % (v, k))
print("PREDICTED-DBS=%d PREDICTED-HOISTS=%d PREDICTED-WRAPPERS=%d PREDICTED-CANDIDATES=%d"
      % (tot["dbs"], tot["hoists"], tot["wrappers"], tot["candidates"]))
