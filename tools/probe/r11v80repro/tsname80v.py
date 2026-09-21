#!/usr/bin/env python3
"""v11u80 verifier — print, for every top-level holder in a dump section, the
holder kind, its vpiTypespec's ACTUAL typespec kind and NAME, plus the
compared scalar flags.  Spans are stripped; names are printed verbatim so a
QUALIFIED vs UNQUALIFIED typespec name is visible (typespec::Compare reads
VpiName through BaseClass::Compare)."""
import re
import sys

SECT = re.compile(r"^\|(\w+):\s*$")
TOP = re.compile(r"^  \\_(\w+): \(([^)]*)\)")
ACT = re.compile(r"^      \\_(\w+):\s*(\(([^)]*)\))?")


def rows(path, section):
    L = open(path, encoding="utf8", errors="replace").read().split("\n")
    cur = None
    out = []
    i = 0
    while i < len(L):
        m = SECT.match(L[i])
        if m:
            cur = m.group(1)
            i += 1
            continue
        m = TOP.match(L[i])
        if m and (section is None or cur == section):
            kind, name = m.group(1), m.group(2)
            ts = None
            flags = []
            j = i + 1
            while j < len(L):
                ll = L[j]
                if TOP.match(ll) or SECT.match(ll) or (ll and not ll.startswith("    ") and not ll.startswith("  |")):
                    break
                if ll.startswith("      |vpiActual:") and ts is None:
                    a = ACT.match(L[j + 1])
                    if a:
                        ts = a.group(1) + ("(" + (a.group(3) or "") + ")")
                f = re.match(r"^    \|(vpi\w+):(.*)$", ll)
                if f and f.group(1) in ("vpiSize", "vpiAutomatic", "vpiVisibility",
                                        "vpiRandType", "vpiArrayType", "vpiNetType",
                                        "vpiSigned", "vpiConstantVariable", "vpiName"):
                    flags.append(f.group(1)[3:] + "=" + f.group(2).strip())
                j += 1
            out.append((cur, name, kind, ts, " ".join(flags)))
            i = j
            continue
        i += 1
    return out


def main():
    sect = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] != "." else None
    rx = re.compile(sys.argv[3]) if len(sys.argv) > 3 else re.compile(".")
    for r in rows(sys.argv[1], sect):
        if rx.search(r[1]):
            print("%-14s %-24s %-12s ts=%-28s %s" % r)


main()
