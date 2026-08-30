#!/usr/bin/env python3
"""r10uvm162 — THE A-PRIORI MOVER PREDICTION, made from the PRISTINE
databases only.  MEASUREMENT ONLY.  G is ALWAYS golden (Surelog).

Reads a `predsweep162.sh` output and splits its `PRED-TOWARD-OP` cells — the
concatenations golden fills and our pristine database leaves with a NULL
operand vector — into the ones § badConcatCompoundOperands162 RECOVERS and the
ones it ABSTAINS on, using a predicate evaluated on GOLDEN's own operand kind
list.

§ 160's five ATOMIC shapes can only ever produce a `constant`, a `ref_obj` or a
`hier_path`; § 162's four COMPOUND shapes (a ternary, a binary operator, a
nested concatenation, a replication) add `operation`.  Anything else — a
`func_call`, a `sys_func_call`, a `bit_select`, a `part_select`, a bare
`method_func_call` — is a shape the law leaves exactly as it is.

The predicate is evaluated on the TOP-LEVEL operand kinds only, so it is
DELIBERATELY OPTIMISTIC about an `operation` operand: whether that operation's
own sub-operands are admitted, recursively, cannot be read off this list.  Each
`RECOVER` cell carrying an `operation` must therefore be checked by hand
against golden's own dump before it is believed — which is what §4 of the pass
README does for the two cells this pass adds.

It then prints the DATABASES that must move, BY NAME.  Nothing here reads a
patched database; that is the point.

usage: predmovers162.py <PREDICT.tsv>
"""
import re, sys, collections

RECOVERABLE = {"constant", "ref_obj", "hier_path", "operation"}
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
