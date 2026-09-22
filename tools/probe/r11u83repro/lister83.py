#!/usr/bin/env python3
"""r11u83 SHAPE LISTER (the r11v74/r11v75 resolving generation, taught to
descend).

r11u77's `lister77.py` reads a module's listing at dump indent 2 and nothing
else, so an INTERFACE's listing — which lives nested inside the module block
of `uhdmtopModules` — is invisible to it.  This pass's ground IS that nested
listing, so the lister tracks the OWNER by indentation and emits one row per
`vpiVariables` / `vpiNet` / `vpiArrayNet` slot at ANY depth:

    (section, owner, slot, kind, name, span, vpiNetType)

`span` is the DECLARATION span, which is what distinguishes a hoisted
imported copy (the package's own line) from the body's own namesake (the
body's line) — the w1_iface distinguisher.

usage: lister83.py <dump> [<dump2> ...]
       DIFF=1 lister83.py <gold.dump> <ours.dump>
"""
import os
import re
import sys

SLOTS = ("vpiVariables", "vpiNet", "vpiNets", "vpiArrayNet", "vpiArrayNets")


def parse(fn):
    L = open(fn, errors="replace").read().splitlines()
    sect = "?"
    rows = []
    # owner stack keyed by indent of the object's own line
    owners = []  # list of (indent, name)
    for i, l in enumerate(L):
        m = re.match(r"^\|(uhdm\w+|weaklyReferenced\w*):", l)
        if m:
            sect = m.group(1)
            owners = []
            continue
        mo = re.match(r"^(\s*)\\_(\w+):\s*(.*)$", l)
        if mo:
            ind = len(mo.group(1))
            kind = mo.group(2)
            rest = mo.group(3)
            nm = re.search(r"\(([^)]*)\)", rest)
            nm = nm.group(1) if nm else ""
            if kind in ("module_inst", "interface_inst", "gen_scope",
                        "package", "program"):
                while owners and owners[-1][0] >= ind:
                    owners.pop()
                owners.append((ind, nm or kind))
        ms = re.match(r"^(\s*)\|(\w+):\s*$", l)
        if not ms or ms.group(2) not in SLOTS:
            continue
        ind = len(ms.group(1))
        o = L[i + 1] if i + 1 < len(L) else ""
        mo2 = re.match(r"^\s*\\_(\w+):\s*(.*)$", o)
        if not mo2:
            continue
        kind = mo2.group(1)
        rest = mo2.group(2)
        nm = re.search(r"\(([^)]*)\)", rest)
        nm = nm.group(1) if nm else ""
        sp = re.search(r"line:(\d+:\d+), endln:(\d+:\d+)", rest)
        sp = "%s-%s" % (sp.group(1), sp.group(2)) if sp else "-"
        nt = "-"
        j = i + 2
        while j < len(L) and not re.match(r"^\s*\\_\w+:", L[j]):
            mn = re.match(r"^\s*\|vpiNetType:(\d+)", L[j])
            if mn:
                nt = mn.group(1)
                break
            j += 1
        own = "?"
        for (oi, on) in owners:
            if oi < ind:
                own = on
        rows.append((sect, own, ms.group(2), kind, nm, sp, nt))
    return rows


def fmt(r):
    return "%-16s %-26s %-13s %-13s %-28s %-14s nt=%s" % r


def main():
    fns = sys.argv[1:]
    if os.environ.get("DIFF") and len(fns) == 2:
        a = parse(fns[0])
        b = parse(fns[1])
        # multiset join on (section, owner, slot, kind, name, span, nt)
        from collections import Counter
        ca, cb = Counter(a), Counter(b)
        keys = sorted(set(ca) | set(cb))
        for k in keys:
            na, nb = ca[k], cb[k]
            if na == nb:
                continue
            print("%s GOLD=%d OURS=%d  %s" %
                  ("!!" if nb == 0 or na == 0 else "~ ", na, nb, fmt(k)))
        print("# gold rows %d ours rows %d" % (len(a), len(b)))
        return
    for fn in fns:
        print("#### " + fn)
        for r in parse(fn):
            print(fmt(r))


main()
