#!/usr/bin/env python3
"""castgrid51 — per-cont_assign RHS SHAPE reader for a uhdm-dump.

Usage:  castgrid51.py <dump> [--view=def|top|both] [--only-ops]

The ONE question r10earl51 asks of a dump: for each `cont_assign`, is its
`vpiRhs` an OPERATION (which vpiOpType) or a folded CONSTANT?

Rows are keyed on `<enclosing instance fullname> <source span>` so a cell is
identifiable across golden and ours (spans are identical; ids and arena order
are not).  A cont_assign printed WITHOUT a body was already emitted earlier in
the dump (Surelog/we SHARE one object between the def and elab views); such a
row is resolved against the DEF view's answer for the same span and marked
`=def`, because content — not object identity — is what uhdm-cmp compares.
"""
import sys


def indent_of(line):
    n = 0
    for ch in line:
        if ch == " ":
            n += 1
        else:
            break
    return n


VALKEYS = ("UINT", "INT", "BIN", "HEX", "OCT", "STRING", "REAL")


def describe_rhs(lines, k, hi):
    """k indexes the object line right after `|vpiRhs:`."""
    obj = lines[k].strip()
    kind = obj.split(":")[0].replace("\\_", "")
    obase = indent_of(lines[k])
    if kind == "operation":
        m = k + 1
        while m < hi:
            l3 = lines[m]
            if not l3.strip():
                m += 1
                continue
            if indent_of(l3) < obase:
                break
            s3 = l3.strip()
            if indent_of(l3) == obase and s3.startswith("|vpiOpType:"):
                return "operation op=%s" % s3[len("|vpiOpType:"):]
            m += 1
        return "operation op=shared"
    if kind == "constant":
        m, val, size = k + 1, "", ""
        while m < hi:
            l3 = lines[m]
            if not l3.strip():
                m += 1
                continue
            if indent_of(l3) < obase:
                break
            s3 = l3.strip()
            if indent_of(l3) == obase and s3.startswith("|"):
                if s3.startswith("|vpiSize:"):
                    size = s3[len("|vpiSize:"):]
                elif ":" in s3 and s3[1:].split(":")[0] in VALKEYS:
                    val = s3[1:]
            m += 1
        if not val and not size:
            return "constant (shared)"
        return "constant %s sz=%s" % (val or "-", size or "-")
    return kind


def scan(lines, lo, hi):
    """Yield (scope, span, rhs) for every cont_assign header in [lo,hi)."""
    out = []
    scope_stack = []  # (indent, name)
    for i in range(lo, hi):
        ln = lines[i]
        st = ln.lstrip()
        ind = indent_of(ln)
        if st.startswith("\\_module_inst: ") or st.startswith("\\_interface_inst: "):
            nm = st.split(": ", 1)[1]
            nm = nm.split(" (")[0]
            while scope_stack and scope_stack[-1][0] >= ind:
                scope_stack.pop()
            scope_stack.append((ind, nm))
            continue
        if not st.startswith("\\_cont_assign: "):
            continue
        # a cont_assign is a CHILD row of its instance: only accept it when it
        # is introduced by `|vpiContAssign:` on the previous line (the parent
        # chain reprints of nested objects are not cells).
        if i == 0 or lines[i - 1].strip() != "|vpiContAssign:":
            continue
        while scope_stack and scope_stack[-1][0] >= ind:
            scope_stack.pop()
        scope = scope_stack[-1][1] if scope_stack else "?"
        span = st[len("\\_cont_assign: "):].strip()
        base = ind
        rhs = "(shared)"
        j = i + 1
        while j < hi:
            l2 = lines[j]
            if not l2.strip():
                j += 1
                continue
            if indent_of(l2) < base + 2:
                break
            if indent_of(l2) == base + 2 and l2.strip() == "|vpiRhs:":
                rhs = describe_rhs(lines, j + 1, hi)
                break
            j += 1
        out.append((scope, span, rhs))
    return out


def main():
    path = sys.argv[1]
    view = "both"
    only_ops = False
    for a in sys.argv[2:]:
        if a.startswith("--view="):
            view = a.split("=", 1)[1]
        elif a == "--only-ops":
            only_ops = True
    with open(path, errors="replace") as f:
        lines = f.read().split("\n")
    first_top = len(lines)
    for n, l in enumerate(lines):
        if l.rstrip() == "|uhdmtopModules:":
            first_top = n
            break
    defrows = scan(lines, 0, first_top)
    defmap = {}
    for scope, span, rhs in defrows:
        defmap.setdefault((scope, span), rhs)
    if view in ("def", "both"):
        for scope, span, rhs in defrows:
            if only_ops and not rhs.startswith("operation"):
                continue
            print("DEF %s %s | %s" % (scope, span, rhs))
    if view in ("top", "both"):
        for scope, span, rhs in scan(lines, first_top, len(lines)):
            if rhs == "(shared)":
                rhs = defmap.get((scope, span), "(shared,unresolved)") + " =def"
            if only_ops and not rhs.startswith("operation"):
                continue
            print("TOP %s %s | %s" % (scope, span, rhs))


main()
