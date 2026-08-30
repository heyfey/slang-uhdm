#!/usr/bin/env python3
"""r10uvm162 — the A-PRIORI predicate, evaluated on ONE row's two PRISTINE
censuses (golden + ours).  MEASUREMENT ONLY.  G is ALWAYS golden (Surelog).

The brief's question 3: every OPERATION, ASSIGNMENT Rhs, CALL ARGUMENT list,
CONDITION and hier_path element list whose GOLDEN side is PRESENT and ours is
ABSENT or TRUNCATED, keyed by context and view.  Both one-sided sets are
printed; the AWAY set must stay empty.

Buckets (row type is the suffix):
  PRED-TOWARD-OP    golden's vpiOperand vector is non-empty, ours is NULL(-1)
                    or EMPTY(0) at the same (view, owner, span, opType) key
  PRED-TRUNC-OP     both non-empty, golden's is LONGER
  PRED-AWAY-OP      the mirror of TOWARD (ours listed, golden's null/empty)
  PRED-GROW-OP      the mirror of TRUNC (ours LONGER)
  PRED-TOWARD-ASGN  golden has an Rhs, ours has none, same key
  PRED-AWAY-ASGN    the mirror
  PRED-TOWARD-ARG / PRED-AWAY-ARG      the tf_call argument vector
  PRED-TOWARD-COND / PRED-AWAY-COND    the condition expression
  PRED-TOWARD-HP / PRED-AWAY-HP        the hier_path element vector
  ONLYG-<type> / ONLYO-<type>          the key exists on ONE side only

A NULL vector (-1) and an EMPTY one (0) are DIFFERENT answers to the judge
(BaseClass.h's vector SafeCompare), so both are printed as written.

usage: predjoin162.py <cen.g.tsv> <cen.o.tsv>
"""
import sys, collections

# row type -> (key field indexes, value field indexes)
SPEC = {
    "OP":   ((2, 5, 6, 7), (8, 9, 10)),
    "ASGN": ((2, 5, 6, 7), (8, 9)),
    "ARG":  ((2, 5, 6, 7, 8), (9, 10)),
    "COND": ((2, 5, 6, 7), (8,)),
    "HP":   ((2, 5, 6, 7), (8, 9)),
}
MINF = {"OP": 11, "ASGN": 11, "ARG": 11, "COND": 10, "HP": 10}


def load(p):
    m = collections.defaultdict(lambda: collections.defaultdict(list))
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 3:
            continue
        rt = f[1]
        if rt not in SPEC or len(f) < MINF[rt]:
            continue
        k, v = SPEC[rt]
        m[rt][tuple(f[i] for i in k)].append(tuple(f[i] for i in v))
    return m


def emit(tag, rt, key, gv, ov):
    print("%s-%s\t%s\tG=%s\tO=%s" % (tag, rt, "\t".join(key), sorted(gv), sorted(ov)))


g, o = load(sys.argv[1]), load(sys.argv[2])
for rt in SPEC:
    gk, ok = g.get(rt, {}), o.get(rt, {})
    for key in sorted(set(gk) | set(ok)):
        gv, ov = gk.get(key), ok.get(key)
        if gv is None:
            emit("ONLYO", rt, key, [], ov)
            continue
        if ov is None:
            emit("ONLYG", rt, key, gv, [])
            continue
        if rt in ("OP", "ARG", "HP"):
            # the vector SIZE column is the FIRST value field for OP/HP, the
            # first for ARG too (see ct162cen's column order).
            idx = 1 if rt == "OP" else 0
            gn = {int(v[idx]) for v in gv}
            on = {int(v[idx]) for v in ov}
            if max(gn) > 0 and max(on) <= 0:
                emit("PRED-TOWARD", rt, key, gv, ov)
            elif max(on) > 0 and max(gn) <= 0:
                emit("PRED-AWAY", rt, key, gv, ov)
            elif max(gn) > max(on) > 0:
                emit("PRED-TRUNC", rt, key, gv, ov)
            elif max(on) > max(gn) > 0:
                emit("PRED-GROW", rt, key, gv, ov)
        elif rt == "ASGN":
            gr = {v[1] for v in gv}
            orr = {v[1] for v in ov}
            if gr != {"<null>"} and orr == {"<null>"}:
                emit("PRED-TOWARD", rt, key, gv, ov)
            elif orr != {"<null>"} and gr == {"<null>"}:
                emit("PRED-AWAY", rt, key, gv, ov)
        elif rt == "COND":
            gr = {v[0] for v in gv}
            orr = {v[0] for v in ov}
            if gr != {"<null>"} and orr == {"<null>"}:
                emit("PRED-TOWARD", rt, key, gv, ov)
            elif orr != {"<null>"} and gr == {"<null>"}:
                emit("PRED-AWAY", rt, key, gv, ov)
