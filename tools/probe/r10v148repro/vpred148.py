#!/usr/bin/env python3
"""r10v148 (VERIFIER) — A-PRIORI MOVER PREDICTION from PRISTINE databases only.
MEASUREMENT ONLY.

Reads ct148cen rows and names, per database, the cells § tfItemLocalLosesToPkgVar148
and the fork half of § pkgSubRefBindsPkgVarOverFormal81 must move:

  LOCAL half  PROD=TFITEM & LOC=FUNC & PKGV=1 & BSK in (function,task)
              -> the TF-ITEM body local we bind and golden gives the package
  FORMAL half LOC=FORMAL & PKGV=1 & FORK=1 & BSK=package & ROLE=COND
              -> a predicate under a fork we late-bound and golden keeps as the formal

The COND/early-bound refinement is NOT applied to the local half here: the
census cannot see whether the enclosing chain is a plain begin or a loop, so the
count is an UPPER BOUND per database and the DATABASE SET is the prediction.
"""
import sys, collections
cand = collections.Counter(); fork = collections.Counter()
for path in sys.argv[1:]:
    tag = path
    for ln in open(path):
        if not ln.startswith("ROW="): continue
        d = dict(f.split("=",1) for f in ln.rstrip("\n").split("|") if "=" in f)
        if d.get("PROD")=="TFITEM" and d.get("LOC")=="FUNC" and d.get("PKGV")=="1" \
           and d.get("BSK") in ("function","task"):
            cand[tag]+=1
        if d.get("LOC")=="FORMAL" and d.get("PKGV")=="1" and d.get("FORK")=="1" \
           and d.get("BSK")=="package" and d.get("ROLE")=="COND":
            fork[tag]+=1
for t in sorted(set(cand)|set(fork)):
    print("PRED %s local=%d forkformal=%d" % (t, cand[t], fork[t]))
print("PRED_DBS=%d" % len(set(cand)|set(fork)))
