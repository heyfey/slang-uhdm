#!/usr/bin/env python3
"""r11u55 ROAD-E CELL READER.

Print, per VIEW (DEF = the `uhdmall*` listing, ELAB = the `uhdmtop*` listing,
TAIL = `weaklyReferenced`) and per cont_assign, the Lhs object and the Rhs
object (kind, name, location, vpiSize, vpiConstType, vpiValue, vpiDecompile).

WHY VIEW-SECTIONED: `UhdmWriter::writeCont_assign` runs per ELABORATED
INSTANCE, and `compileContinuousAssignment` compiles the definition listing
with a hard `Reduce::No`.  "Golden folds `CFG.n`" is never a whole-design fact
-- it is a fact about the ELAB copy only.

WHY vpiParent SUBTREES ARE SKIPPED: uhdm-dump prints the back-link as a full
child block, so a naive indentation walk sees every cont_assign three times
and reads its own parent as its Rhs.

GUARD: an arm that yields ZERO cont_assign records prints NONE and exits 4, so
a reader that reaches nothing can never read as agreement.

usage: caread55.py <dump> [DEF|ELAB|TAIL|ALL] [--paths]
"""
import re
import sys

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+):\s*(.*)$')
ATT = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
LOC = re.compile(r'\bline:(\d+:\d+)')
FIELDS = ("vpiSize", "vpiConstType", "vpiValue", "vpiDecompile")


def indent(line):
    n = 0
    for ch in line:
        if ch == ' ':
            n += 1
        else:
            break
    return n


def parse(path, want, show_paths):
    out = []
    lines = open(path, errors="replace").read().splitlines()
    n = len(lines)
    # FIRST PASS: the view of every line.  The record walk skips whole
    # subtrees, so it must never be the thing that sees the section markers.
    views = [None] * n
    v = "HEAD"
    for k, ln in enumerate(lines):
        if "uhdmallModules:" in ln or "uhdmallPackages:" in ln or "uhdmallClasses:" in ln:
            v = "DEF"
        elif "uhdmtopModules:" in ln or "uhdmtopPackages:" in ln:
            v = "ELAB"
        elif "weaklyReferenced:" in ln:
            v = "TAIL"
        views[k] = v
    i = 0
    total = 0
    while i < n:
        ln = lines[i]
        view = views[i]
        m = OBJ.match(ln)
        if not m or m.group(2) != "cont_assign":
            i += 1
            continue
        base = indent(ln)
        caloc = LOC.search(ln)
        caloc = caloc.group(1) if caloc else "-"
        # collect the cont_assign's own children, skipping vpiParent subtrees
        lhs = rhs = None
        j = i + 1
        skip_to = None
        while j < n:
            l2 = lines[j]
            if indent(l2) <= base and (OBJ.match(l2) or l2.strip() == ""):
                break
            a = ATT.match(l2)
            if a and indent(l2) == base + 2:
                key = a.group(2)
                skip_to = key
            elif OBJ.match(l2) and indent(l2) == base + 2:
                if skip_to == "vpiLhs" and lhs is None:
                    lhs = (j, indent(l2))
                elif skip_to == "vpiRhs" and rhs is None:
                    rhs = (j, indent(l2))
            j += 1
        total += 1

        def describe(rec):
            if rec is None:
                return "<none>", "-", ""
            k, ind0 = rec
            mo = OBJ.match(lines[k])
            kind = mo.group(2)
            nm = mo.group(3).split(",")[0].strip()
            loc = LOC.search(lines[k])
            loc = loc.group(1) if loc else "NOLOC"
            det = []
            # the object's own attributes: deeper lines until indent drops back
            q = k + 1
            sub = None
            while q < n and indent(lines[q]) > ind0:
                a2 = ATT.match(lines[q])
                if a2 and indent(lines[q]) == ind0 + 2:
                    sub = a2.group(2)
                    if sub in FIELDS:
                        det.append("%s:%s" % (sub, a2.group(3).strip()))
                q += 1
            return kind + (("(" + nm + ")") if nm else ""), loc, " ".join(det)

        lk, ll, _ = describe(lhs)
        rk, rl, rd = describe(rhs)
        if want in ("ALL", view):
            out.append("%-4s ca@%-9s LHS=%-26s@%-9s RHS=%-16s@%-9s %s"
                       % (view, caloc, lk, ll, rk, rl, rd))
        i = j
    if total == 0:
        print("NONE: no cont_assign reached in %s" % path)
        sys.exit(4)
    for o in out:
        print(o)


if __name__ == "__main__":
    p = sys.argv[1]
    w = sys.argv[2] if len(sys.argv) > 2 else "ALL"
    parse(p, w, "--paths" in sys.argv)
