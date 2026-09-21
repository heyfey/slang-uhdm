#!/usr/bin/env python3
"""r11u75 RESOLVING LISTER — one row per cont_assign, Lhs object and its actual.

Reads a `uhdm-dump` text dump and prints, for every `cont_assign`, the SECTION
it lives in (`uhdmallModules` = the definition listing, `uhdmtopModules` =
elaborated, `uhdmallPackages`/`uhdmtopPackages`, `weaklyReferenced` = the
unreachable tail), the Lhs object kind and name, the Lhs ref's `vpiActual`
(kind + fullname, or `-` when there is none), and the Rhs's shape (kind, plus
the value for a constant).

The row is the judge's own reading order: `cont_assign::Compare` ->
`SafeCompare(Lhs)` -> `ref_obj::Compare` -> `SafeCompare(Actual_group)`.  A
`-` on one side and an object on the other is a HEAD, which is why the actual
is printed verbatim and never summarised.

usage: calist75.py <dump> [<dump2> ...]      (one block per dump)
       DIFF=1 calist75.py <goldendump> <oursdump>   (joined, ours vs golden)
"""
import os, re, sys


def indent(l):
    return len(l) - len(l.lstrip(" "))


def parse(fn):
    L = open(fn, errors="replace").read().splitlines()
    # Section = the last top-level "|uhdm<X>:" / "|weaklyReferenced" seen.
    sect = "?"
    sections = []
    for l in L:
        m = re.match(r"^\|(uhdm\w+|weaklyReferenced\w*):", l)
        if m:
            sect = m.group(1)
        sections.append(sect)
    rows = []
    for i, l in enumerate(L):
        if not re.match(r"^\s*\\_cont_assign:", l):
            continue
        base = indent(l)
        # The cont_assign's own attributes are the lines indented by base+2
        # whose deeper children belong to them.
        lhs = rhs = None
        j = i + 1
        while j < len(L) and indent(L[j]) > base:
            if indent(L[j]) == base + 2 and L[j].strip().startswith("|vpiLhs:"):
                lhs = j
            if indent(L[j]) == base + 2 and L[j].strip().startswith("|vpiRhs:"):
                rhs = j
            j += 1
        end = j

        def obj(k):
            if k is None or k + 1 >= len(L):
                return ("-", "-", None)
            o = L[k + 1]
            m = re.match(r"^\s*\\_(\w+):\s*(.*)$", o)
            if not m:
                return ("-", "-", None)
            return (m.group(1), m.group(2).strip(), k + 1)

        lk, ltxt, lpos = obj(lhs)
        rk, rtxt, rpos = obj(rhs)
        # The Lhs object's name and its actual.
        lname, lact = "-", "-"
        if lpos is not None:
            b2 = indent(L[lpos])
            k = lpos + 1
            while k < len(L) and indent(L[k]) > b2:
                s = L[k].strip()
                if indent(L[k]) == b2 + 2 and s.startswith("|vpiFullName:"):
                    lname = s.split(":", 1)[1]
                if indent(L[k]) == b2 + 2 and s.startswith("|vpiActual:"):
                    m = re.match(r"^\s*\\_(\w+):\s*(.*)$", L[k + 1])
                    lact = ("%s %s" % (m.group(1), m.group(2).strip())) if m else "?"
                k += 1
        # The Rhs shape: the kind, and for a constant its value/size.
        rshape = rk
        if rpos is not None and rk == "constant":
            b2 = indent(L[rpos])
            k, val, sz = rpos + 1, "", ""
            while k < len(L) and indent(L[k]) > b2:
                s = L[k].strip()
                if re.match(r"^\|(BIN|UINT|INT|STRING|HEX|OCT|REAL|SCAL):", s):
                    val = s[1:]
                if s.startswith("|vpiSize:"):
                    sz = s.split(":", 1)[1]
                k += 1
            rshape = "constant %s sz=%s" % (val, sz)
        rows.append((sections[i], lk, lname, lact, rshape, i))
    return rows


def key(r):
    return (r[0], r[2], r[4])


def show(fn):
    print("== %s" % fn)
    print("%-16s %-14s %-34s %-42s %s" % ("section", "lhs_kind", "lhs_fullname", "lhs_vpiActual", "rhs"))
    for r in parse(fn):
        print("%-16s %-14s %-34s %-42s %s" % (r[0], r[1], r[2], r[3], r[4]))


if __name__ == "__main__":
    if os.environ.get("DIFF") and len(sys.argv) >= 3:
        g, o = parse(sys.argv[1]), parse(sys.argv[2])
        # Join on (section, lhs fullname): the multiset trap is avoided by
        # consuming each golden row at most once.
        used = [False] * len(g)
        print("%-3s %-16s %-30s %-40s %s" % ("", "section", "lhs_fullname", "GOLDEN actual", "OURS actual"))
        for r in o:
            hit = None
            for idx, q in enumerate(g):
                if not used[idx] and q[0] == r[0] and q[2] == r[2]:
                    hit, used[idx] = q, True
                    break
            if hit is None:
                print("%-3s %-16s %-30s %-40s %s" % ("+O", r[0], r[2], "<no golden row>", r[3]))
            elif hit[3] != r[3] or hit[4] != r[4]:
                mark = "!!" if hit[3] != r[3] else "~"
                print("%-3s %-16s %-30s %-40s %s" % (mark, r[0], r[2], hit[3], r[3]))
                if hit[4] != r[4]:
                    print("%-3s %-16s %-30s   rhs G: %s\n%-3s %-16s %-30s   rhs O: %s"
                          % ("", "", "", hit[4], "", "", "", r[4]))
        for idx, q in enumerate(g):
            if not used[idx]:
                print("%-3s %-16s %-30s %-40s %s" % ("+G", q[0], q[2], q[3], "<no ours row>"))
    else:
        for fn in sys.argv[1:]:
            show(fn)
