#!/usr/bin/env python3
"""r10uvm162 — THE THREE-WAY CELL SCORER (golden vs pristine vs patched).

r10uvm158repro/score158.py's taxonomy and multiset discipline, over
ct162cen.cpp's row families.  MEASUREMENT ONLY; the official uhdm-cmp is the
judge.  G is ALWAYS golden (Surelog); A is ALWAYS the PRISTINE binary, B
ALWAYS the PATCHED one.

Payloads are compared as SETS per key (a dict would drop colliding keys —
RESUME.md §9), and a key present on one side only is still printed and
COUNTED.  The VIEW is deliberately OUT of the key (the two producers label the
def and elab listings differently) — both views' censuses are concatenated by
the driver, so a cell listed in both views collapses to one key with one
payload set, and a cell that DIFFERS between views shows as two payloads.

  OP    key (owner, span, vpiOpType)          payload (parent kind, NOPS, OPLIST)
  ASGN  key (owner, span, kind)               payload (LHS, RHS[, Rhs span])
  ARG   key (owner, span, kind, name)         payload (NARGS, ARGLIST)
  COND  key (owner, span, kind)               payload (condition)
  HP    key (owner, span, name)               payload (NELEMS, ELEMLIST)

NOPS/NARGS/NELEMS are the census's NULL-vs-EMPTY tokens: -1 is a NULL vector,
0 a present-but-empty one; the judge treats those as different answers.

Every cell is classified against golden:
  RIGHT      A==G and B==G          (nothing moved, nothing broke)
  TOWARD     A!=G and B==G          (the fix)
  WRONG      A==G and B!=G          (a REGRESSION — must be 0)
  STILL      A!=G, B!=G, A==B       (untouched residue)
  RESHAPE    A!=G, B!=G, A!=B       (moved, still wrong — must be justified)
  ONLY-G     in golden, in neither of ours
  AWAY       in B, in NEITHER G nor A (we INVENTED it — must be 0)
  ONLY-OURS  in A and B, not in G
  ONLY-A     in A only (we DELETED it: also reported)

usage: score162.py <cen.g.txt> <cen.a.txt> <cen.b.txt>
                   [--rows OP|ASGN|ARG|COND|HP|ALL] [--nospan]
"""
import sys, collections

def load(p, want, nospan=False):
    m = collections.defaultdict(set)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 3:
            continue
        rt = f[1]
        if rt not in (want, "ALL") and want != "ALL":
            continue
        if rt == "OP" and len(f) >= 11:
            m[("OP", f[5], f[6], f[7])].add((f[8], f[9], f[10]))
        elif rt == "ASGN" and len(f) >= 11:
            m[("ASGN", f[5], f[6], f[7])].add(
                (f[8], f[9]) if nospan else (f[8], f[9], f[10]))
        elif rt == "ARG" and len(f) >= 11:
            m[("ARG", f[5], f[6], f[7], f[8])].add((f[9], f[10]))
        elif rt == "COND" and len(f) >= 10:
            m[("COND", f[5], f[6], f[7])].add((f[8],))
        elif rt == "HP" and len(f) >= 10:
            m[("HP", f[5], f[6], f[7])].add((f[8], f[9]))
    return m

def main():
    want = "ALL"
    args = list(sys.argv[1:])
    nospan = "--nospan" in args
    if nospan:
        args.remove("--nospan")
    if "--rows" in args:
        i = args.index("--rows"); want = args[i + 1]; del args[i:i + 2]
    g, a, b = (load(args[0], want, nospan), load(args[1], want, nospan),
               load(args[2], want, nospan))
    keys = sorted(set(g) | set(a) | set(b))
    n = collections.Counter()
    for k in keys:
        gv, av, bv = g.get(k, set()), a.get(k, set()), b.get(k, set())
        if not gv and not bv and av:
            n["ONLY-A"] += 1; print("ONLY-A\t%s\t%s" % (k, sorted(av))); continue
        if not gv and bv:
            tok = "AWAY" if not av else "ONLY-OURS"
            n[tok] += 1
            print("%s\t%s\tA=%s B=%s" % (tok, k, sorted(av), sorted(bv))); continue
        if not av and not bv:
            n["ONLY-G"] += 1; print("ONLY-G\t%s\t%s" % (k, sorted(gv))); continue
        if av == gv and bv == gv:
            n["RIGHT"] += 1; continue
        if av != gv and bv == gv:
            n["TOWARD"] += 1
            print("TOWARD\t%s\n\tG=%s\n\tA=%s" % (k, sorted(gv), sorted(av))); continue
        if av == gv and bv != gv:
            n["WRONG"] += 1
            print("WRONG\t%s\n\tG=%s\n\tB=%s" % (k, sorted(gv), sorted(bv))); continue
        if av == bv:
            n["STILL"] += 1
            print("STILL\t%s\n\tG=%s\n\tA=B=%s" % (k, sorted(gv), sorted(av))); continue
        n["RESHAPE"] += 1
        print("RESHAPE\t%s\n\tG=%s\n\tA=%s\n\tB=%s"
              % (k, sorted(gv), sorted(av), sorted(bv)))
    print("-- rows=%s RIGHT=%d TOWARD=%d WRONG=%d STILL=%d RESHAPE=%d "
          "ONLY-G=%d AWAY=%d ONLY-OURS=%d ONLY-A=%d"
          % (want, n["RIGHT"], n["TOWARD"], n["WRONG"], n["STILL"], n["RESHAPE"],
             n["ONLY-G"], n["AWAY"], n["ONLY-OURS"], n["ONLY-A"]))

main()
