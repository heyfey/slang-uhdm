#!/usr/bin/env python3
"""r10uvm160 — THE A-PRIORI MOVER PREDICTION, made from the PRISTINE
databases only.  MEASUREMENT ONLY.  G is ALWAYS golden (Surelog).

Reads a `predsweep160.sh` output and splits its `PRED-TOWARD-OP` cells — the
concatenations golden fills and our pristine database leaves with a NULL
operand vector — into the ones § badConcatOperandsFromSyntax160 RECOVERS and
the ones it ABSTAINS on, using a predicate evaluated on GOLDEN's own operand
kind list: the five modelled operand shapes can only ever produce a
`constant`, a `ref_obj` or a `hier_path`, so a cell whose golden operand list
holds anything else (a nested `operation`, a `func_call`, a `bit_select`, …)
is one the law leaves exactly as it is.

It then prints the DATABASES that must move, BY NAME.  Nothing here reads a
patched database; that is the point.

usage: predmovers160.py <PREDICT.tsv>
"""
import re, sys, collections

RECOVERABLE = {"constant", "ref_obj", "hier_path"}
rows = collections.defaultdict(lambda: {"rec": [], "abs": []})
for ln in open(sys.argv[1]):
    f = ln.rstrip("\n").split("\t")
    if len(f) < 3 or f[1] != "PRED-TOWARD-OP":
        continue
    row, view, owner, span, opt = f[0], f[2], f[3], f[4], f[5]
    ops = set(re.findall(r"[a-z_]+(?=\()|(?<=,)[a-z_]+(?=,|'\])", f[-2]))
    kinds = set(re.findall(r"(?:^|,)([a-z_]+)(?:\(|,|$)", f[-2].split("', '")[-1]))
    bad = kinds - RECOVERABLE
    tgt = "abs" if bad else "rec"
    rows[row][tgt].append((view, owner, span, opt, sorted(kinds)))

nrec = nabs = 0
for row in sorted(rows):
    r, a = rows[row]["rec"], rows[row]["abs"]
    nrec += len(r); nabs += len(a)
    print("%-34s RECOVER=%d ABSTAIN=%d" % (row, len(r), len(a)))
    for v in r:
        print("    RECOVER  %s  %s  %s  op%s  %s" % v)
    for v in a:
        print("    ABSTAIN  %s  %s  %s  op%s  %s" % v)
print("-- databases with >=1 RECOVER cell (the PREDICTED MOVER SET): %d"
      % sum(1 for row in rows if rows[row]["rec"]))
for row in sorted(rows):
    if rows[row]["rec"]:
        print("   MOVER %s" % row)
print("-- cells: RECOVER=%d ABSTAIN=%d" % (nrec, nabs))
