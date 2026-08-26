#!/usr/bin/env python3
"""r10uvm158 — THE THREE-WAY CELL SCORER (golden vs pristine vs patched).

Payloads are compared as SETS per key, exactly as r10uvm155repro/score155.py
does: the two producers list the same object a DIFFERENT NUMBER OF TIMES
across the def and elab views (golden twice, ours three times for a class
member), so a multiset join scores that structural difference on every row and
hides the one column the law moves.  A key present on one side only is still
printed and COUNTED — nothing is silently dropped.

MEASUREMENT ONLY; the official uhdm-cmp is the judge.  G is ALWAYS golden
(Surelog); A is ALWAYS the PRISTINE binary, B ALWAYS the PATCHED one.

Two row families are scored, both as MULTISETS (a dict would drop colliding
keys - RESUME.md section 9):

  BLK   key (owner, span, kind)  payload (name, NVARS, NSTMTS, NPARAM, VARLIST)
  DECL  key (owner, span, name)  payload (var kind, ts kind, ts name, ts inst,
                                          ts span)

The VIEW is deliberately OUT of the key (the two producers label it
differently) but IS carried in the payload-free half of the report by counting
each view's file separately when the caller passes them separately.

Every cell is classified against golden:
  RIGHT        A==G and B==G          (nothing moved, nothing broke)
  TOWARD       A!=G and B==G          (the fix)
  WRONG        A==G and B!=G          (a REGRESSION - must be 0)
  STILL        A!=G, B!=G, A==B       (untouched residue)
  RESHAPE      A!=G, B!=G, A!=B       (moved, still wrong - must be justified)
  ONLY-G       in golden, in neither of ours
  AWAY         in B and NOT in G, and not in A  (we INVENTED it - must be 0)
  ONLY-A       in A only (we DELETED it: also reported)

usage: score158.py <cen.g.txt> <cen.a.txt> <cen.b.txt> [--rows BLK|DECL|ALL]
                   [--nospan]
"""
import sys, collections

def load(p, want, nospan=False):
    m = collections.defaultdict(set)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 3:
            continue
        rt = f[1]
        if rt == "BLK" and want in ("BLK", "ALL"):
            if len(f) < 13:
                continue
            m[("BLK", f[5], f[6], f[7])].add((f[8], f[9], f[10], f[11], f[12]))
        elif rt in ("VAR", "LOCAL", "RET", "PROP", "FORMAL", "MEMBER",
                    "PARAM", "TPARAM") and want in ("DECL", "ALL"):
            if len(f) < 14:
                continue
            m[("DECL", f[5], f[6], f[7])].add(
                (f[8], f[10], f[11], f[12]) if nospan
                else (f[8], f[10], f[11], f[12], f[13]))
    return m

def main():
    want = "ALL"
    args = [a for a in sys.argv[1:]]
    # --nospan drops the bound typespec's LINE:COL from the DECL payload.  The
    # judge never reads a span (RESUME.md section 9: Compare reads
    # VpiType/VpiName/VpiDefName and the per-kind fields, never
    # VpiFile/line/col), and golden binds ONE SHARED typespec object for a type
    # parameter — spanned at the parameter's own default — where we mint one
    # per declaration.  With the span in, every recovered local reads RESHAPE
    # for a column no acceptance gate can see; with it out, the comparison is
    # exactly what uhdm-cmp compares.
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
            n[tok] += 1; print("%s\t%s\tA=%s B=%s" % (tok, k, sorted(av), sorted(bv))); continue
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
        print("RESHAPE\t%s\n\tG=%s\n\tA=%s\n\tB=%s" % (k, sorted(gv), sorted(av), sorted(bv)))
    print("-- rows=%s RIGHT=%d TOWARD=%d WRONG=%d STILL=%d RESHAPE=%d "
          "ONLY-G=%d AWAY=%d ONLY-OURS=%d ONLY-A=%d"
          % (want, n["RIGHT"], n["TOWARD"], n["WRONG"], n["STILL"], n["RESHAPE"],
             n["ONLY-G"], n["AWAY"], n["ONLY-OURS"], n["ONLY-A"]))

main()
