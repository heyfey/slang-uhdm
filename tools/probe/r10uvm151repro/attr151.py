#!/usr/bin/env python3
"""r10uvm151 — ATTRIBUTE a pristine->patched database move to
§ stmtBuiltinBodyIsBareRecvCall151, or convict it.

MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.

    attr151.py <pris.cen> <pat.cen> <pris.dmp> <pat.dmp>

prints  FLIPS=<n> CENBAD=<n> DUMPBAD=<n>  and exits non-zero if either BAD is
non-zero.  `.dmp` files are `uhdm-dump` output with the weakly-referenced tail
CUT OFF, the workdir path removed and `id:` normalised, in EMISSION ORDER (the
order carries the nesting this checker reads).

The law replaces ONE object with ONE object and touches nothing else, so a
moved database must satisfy BOTH halves:

CENSUS half — every ct151cen row that differs must be one leg of a FLIP at a
shared (FILE, ANCH):
      pristine  KIND=MFC  NAME=<method>  PFX=<receiver>
      patched   KIND=FC   NAME=<receiver> PFX=-  NARG=0  WITH=0  FUNC=0
and the number of rows at every anchor must be unchanged.  Anything else —
a row that appeared, a row that vanished, a column that moved on a row that is
not a flip — is CENBAD.

DUMP half — every ADDED dump line must be the new `func_call`'s own header or
its `|vpiName:`, and every REMOVED line must belong to the `method_func_call`
it replaced or to that call's `vpiPrefix` sub-tree (its `ref_obj`, that
ref_obj's back-reference block, its ARGUMENT vector — golden's degenerate
`func_call` has none, `compileTfCallArguments` having landed on the
`paSelect` — and the ONE shallow object header a `|vpiActual:` may print).  A removed or added line of any other shape is
DUMPBAD — that is a change OUTSIDE the law's two objects.
"""
import sys, re, collections, subprocess

SCORED = ["KIND", "NAME", "PFX", "NARG", "WITH", "FUNC"]

def loadcen(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith("CALL "):
            continue
        f = dict(kv.split("=", 1) for kv in ln.split()[1:] if "=" in kv)
        d[(f.get("FILE", "-"), f.get("ANCH", "-"))].append(
            tuple(f.get(c, "-") for c in SCORED))
    for k in d:
        d[k].sort()
    return d

def main():
    o, p = loadcen(sys.argv[1]), loadcen(sys.argv[2])
    flips, cenbad = 0, 0
    names = set()
    for k in set(o) | set(p):
        a, b = o.get(k, []), p.get(k, [])
        if len(a) != len(b):
            cenbad += abs(len(a) - len(b))
            continue
        for x, y in zip(a, b):
            if x == y:
                continue
            if (x[0] == "MFC" and x[2] != "-" and y[0] == "FC" and
                    y[1] == x[2] and y[2] == "-" and y[3] == "0" and
                    y[4] == "0" and y[5] == "0"):
                flips += 1
                names.add(x[1])
                names.add(x[2])
            else:
                cenbad += 1

    # THE DUMP HALF.  `diff` does the alignment (a Python SequenceMatcher on a
    # million-line UVM dump does not finish); its `<` lines are removals and
    # its `>` lines are additions, in emission order, so the nesting the
    # removal grammar reads is intact.
    dumpbad = 0
    ADD_OK = re.compile(r"^\s*(\\_func_call: \(|\|vpiName:)")
    DEL_OK = re.compile(r"^\s*(\\_method_func_call: \(|\\_ref_obj: \(|"
                        r"\|vpiName:|\|vpiPrefix:|\|vpiParent:|\|vpiFullName:|"
                        r"\|vpiActual:|\|vpiArgument:)")
    HDR = re.compile(r"^\s*\\_[A-Za-z_]+: ")
    pr = subprocess.run(["diff", sys.argv[3], sys.argv[4]],
                        capture_output=True, text=True)
    prev_actual = False
    for l in pr.stdout.split("\n"):
        if l.startswith("> "):
            body = l[2:]
            # the dump's first line names the database FILE
            if "Restored design" in body:
                continue
            if not ADD_OK.match(body):
                dumpbad += 1
        elif l.startswith("< "):
            body = l[2:]
            if "Restored design" in body:
                continue
            if DEL_OK.match(body):
                prev_actual = body.lstrip().startswith("|vpiActual:")
                continue
            # the ONE shallow object header a |vpiActual: is allowed to print
            if prev_actual and HDR.match(body):
                prev_actual = False
                continue
            dumpbad += 1
        else:
            prev_actual = False
    print("FLIPS=%d CENBAD=%d DUMPBAD=%d" % (flips, cenbad, dumpbad))
    sys.exit(1 if (cenbad or dumpbad) else 0)

main()
