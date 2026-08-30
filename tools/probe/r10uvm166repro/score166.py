#!/usr/bin/env python3
"""r10uvm166 - THE THREE-WAY CELL SCORE.  MEASUREMENT ONLY; the official
uhdm-cmp is the sole judge.  LHS/G is ALWAYS golden (Surelog).

Descended from r10v155repro/scoreref155.py: the key is NAME-BASED
(VIEW, ROWTYPE, OWNER, NAME), never span-based, because golden spans a
`ref_var` at the WRITTEN TYPE and we span it at the NAME
(CompileType.cpp:421-431 + populateCoreMembers) - a span-keyed join reports a
moved arm as 0 movers.  The payload is the DECLARED OBJECT's kind plus the
bound typespec's kind / name / vpiInstance, with every span dropped.

It reads THREE censuses at once (golden, PRISTINE, PATCHED) and scores each
cell:
   TOWARD   pristine != golden, patched == golden
   AWAY     pristine == golden, patched != golden
   WRONG    both differ from golden AND the patched payload changed - i.e. the
            law minted something that is neither the old answer nor golden's
   STILL    both differ from golden and the patched payload is the pristine one
   SAME     all three agree
A per-field count is printed too, so a cell that moved 1 of 2 fields onto
golden (a RESHAPE) is visible instead of being scored as a miss.

usage: score166.py <cen.g.txt> <cen.pris.txt> <cen.pat.txt> [--list]
"""
import sys, collections

def load(p):
    m = collections.defaultdict(list)
    for ln in open(p):
        f = ln.rstrip("\n").split("\t")
        if len(f) < 14 or f[1] == "TP":
            continue
        # NAME-keyed, with ONE fallback: an object that carries NO VpiName at
        # all (our array element variables do not) would otherwise all pile
        # into a single `-` bucket per owner and read as one giant DIFF, so
        # those rows are keyed on their SPAN instead.  Named rows are NEVER
        # span-keyed - that is the whole point of this scorer.
        nm = f[7]
        # KEY = (which RUN, row type, owner, name).  TWO deliberate choices:
        #  * the RUN (the `-o x.uhdm` database vs the `--elabuhdm` one) IS in
        #    the key, because the two runs are two DIFFERENT databases and
        #    merging them into one multiset manufactures phantoms - it was what
        #    first read `r10vbuvm22repro/v3_kinds.sv` as a regression when both
        #    binaries and golden actually agree per run.
        #  * the ROOT LABEL (DEFPKG / ELABPKG / TOPMOD / ...) is NOT in the key:
        #    RESUME.md sec.9's census law, because the two producers label the
        #    same object's reachability differently.
        run = f[0].split(".", 1)[1] if "." in f[0] else f[0]
        key = (run, f[1], f[5], nm if nm != "-" else "@" + f[6])
        m[key].append((f[8], f[10], f[11], f[12]))
    return {k: sorted(v) for k, v in m.items()}

def fieldscore(gv, xv):
    """Field-level agreement with golden, over the WHOLE multiset.

    Pairing is positional over the two SORTED lists (both are sorted at load),
    truncated to the shorter one, so a cell whose only residue is a DUPLICATE
    listing is scored on the entries it does have rather than being written off.
    Returns (matched fields, comparable fields)."""
    if not gv or not xv:
        return 0, 0
    n = min(len(gv), len(xv))
    tot = mat = 0
    for i in range(n):
        a, b = gv[i], xv[i]
        tot += len(a)
        mat += sum(1 for j in range(len(a)) if a[j] == b[j])
    return mat, tot

g = load(sys.argv[1]); a = load(sys.argv[2]); b = load(sys.argv[3])
show = "--list" in sys.argv
cnt = collections.Counter()
for k in sorted(set(g) | set(a) | set(b)):
    gv, av, bv = g.get(k), a.get(k), b.get(k)
    if av is None and bv is None:
        cnt["ONLY-G"] += 1
        if show: print("ONLY-G\t" + "|".join(k) + "\tG=%s" % (gv,))
        continue
    if gv is None:
        cnt["ONLY-O"] += 1
        if show and av != bv: print("ONLY-O-MOVED\t" + "|".join(k) + "\tP=%s\tQ=%s" % (av, bv))
        continue
    if av == gv and bv == gv:
        cnt["SAME"] += 1; continue
    if av != gv and bv == gv:
        cnt["TOWARD"] += 1
        if show: print("TOWARD\t" + "|".join(k) + "\tG=%s\tPRIS=%s" % (gv, av))
        continue
    if av == gv and bv != gv:
        cnt["AWAY"] += 1
        print("AWAY\t" + "|".join(k) + "\tG=%s\tPAT=%s" % (gv, bv))
        continue
    # both differ from golden
    if av == bv:
        cnt["STILL"] += 1
        if show: print("STILL\t" + "|".join(k) + "\tG=%s\tO=%s" % (gv, av))
    else:
        fa, n = fieldscore(gv, av); fb, _ = fieldscore(gv, bv)
        tag = "RESHAPE-TOWARD" if fb > fa else ("RESHAPE-AWAY" if fb < fa else "WRONG")
        cnt[tag] += 1
        print("%s\t%s\tG=%s\tPRIS=%s(%d/%d)\tPAT=%s(%d/%d)" %
              (tag, "|".join(k), gv, av, fa, n, bv, fb, n))
print("-- " + "  ".join("%s=%d" % (k, cnt[k]) for k in
      ["SAME", "TOWARD", "AWAY", "WRONG", "RESHAPE-TOWARD", "RESHAPE-AWAY",
       "STILL", "ONLY-G", "ONLY-O"]))
