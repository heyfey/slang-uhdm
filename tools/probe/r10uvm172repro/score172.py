#!/usr/bin/env python3
"""r10uvm172 — the statement-call scorer.  MEASUREMENT ONLY; the official
uhdm-cmp is the sole judge.  LHS is ALWAYS golden (Surelog), RHS ALWAYS ours.

Reads two ct172cen listings (golden, ours) and joins them on the KEY
`L<line>#<ord> sub=<name>`.  The value compared is the SHAPE SET — the set of
distinct `kind/name/link/pfx/args` payloads seen at that key — and NOT the
multiplicity: the two producers legitimately emit different COPY COUNTS of the
same body (r10uvm170 residue R6), and a multiplicity join would score that
difference as this law's.  The home chain is stripped: it is evidence, never a
key (RESUME.md §9).

Cells are classified as

  AGREE          the shape sets are equal
  COLLAPSE       golden collapsed the chain (a bare func_call/task_call with a
                 vpiFunction/vpiTask link and NO prefix) where ours holds a
                 method_func_call/method_task_call WITH a prefix  <- the law
  LINKONLY       both sides are a bare func_call/task_call at the same name and
                 span class, and only the LINK differs                <- the law
  OTHER          any other disagreement (someone else's residue)
  G-ONLY/O-ONLY  the key exists on one side only

usage: score172.py <golden.cen> <ours.cen> [--list]
"""
import sys, re
from collections import defaultdict

def load(p):
    d = defaultdict(set)
    for ln in open(p):
        ln = ln.rstrip("\n")
        i = ln.find(" home=")
        if i >= 0:
            ln = ln[:i]
        m = re.match(r"^(L\d+#\d+ sub=\S*) (kind=.*)$", ln)
        if not m:
            continue
        d[m.group(1)].add(m.group(2))
    return d

def isCollapsed(sh):
    return (sh.startswith("kind=func_call ") or sh.startswith("kind=task_call ")) \
           and "pfx=-" in sh
def hasLink(sh):
    return ("link=F:0" not in sh) and ("link=T:0" not in sh)
def isMethod(sh):
    return sh.startswith("kind=method_func_call ") or sh.startswith("kind=method_task_call ")
def hasPfx(sh):
    return " pfx=-" not in sh

def classify(g, o):
    if g == o:
        return "AGREE"
    if all(isCollapsed(x) and hasLink(x) for x in g) and \
       all(isMethod(x) and hasPfx(x) for x in o):
        return "COLLAPSE"
    if all(isCollapsed(x) for x in g) and all(isCollapsed(x) for x in o):
        gn = set(x.split(" link=")[0] for x in g)
        on = set(x.split(" link=")[0] for x in o)
        if gn == on:
            return "LINKONLY"
    return "OTHER"

def main():
    g = load(sys.argv[1]); o = load(sys.argv[2])
    show = "--list" in sys.argv
    counts = defaultdict(int); rows = defaultdict(list)
    for k in set(g) | set(o):
        if k not in o:
            c = "G-ONLY"
        elif k not in g:
            c = "O-ONLY"
        else:
            c = classify(g[k], o[k])
        counts[c] += 1
        if c in ("COLLAPSE", "LINKONLY"):
            rows[c].append((k, sorted(g.get(k, [])), sorted(o.get(k, []))))
    tot = sum(counts.values())
    print("TOTAL %d  " % tot + "  ".join("%s=%d" % (k, counts[k]) for k in sorted(counts)))
    if show:
        for c in ("COLLAPSE", "LINKONLY"):
            for k, gs, os_ in sorted(rows[c]):
                print("%-9s %-40s G=%s | O=%s" % (c, k, gs, os_))

main()
