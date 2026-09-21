#!/usr/bin/env python3
"""r11u77 SHAPE LISTER — the module/package LISTING, one row per top-level
signal slot.  Prints (section, owner, slot, object kind, name, vpiNetType).

The census this pass makes is a LISTING census (which objects the hoist
writes and in what KIND), so the lister beside it must read the listing
itself and never the cont_assign rows `calist77.py` reads.

usage: lister77.py <dump> [<dump2> ...]
       DIFF=1 lister77.py <gold.dump> <ours.dump>
"""
import os, re, sys

SLOTS = ("vpiVariables", "vpiNet", "vpiNets", "vpiArrayNet", "vpiArrayNets")


def parse(fn):
    L = open(fn, errors="replace").read().splitlines()
    sect = "?"
    owner = "?"
    rows = []
    for i, l in enumerate(L):
        m = re.match(r"^\|(uhdm\w+|weaklyReferenced\w*):", l)
        if m:
            sect = m.group(1)
            continue
        ind = len(l) - len(l.lstrip(" "))
        if ind == 0 and l.startswith("\\_"):
            mo = re.match(r"^\\_(\w+):\s*([^,]*)", l)
            if mo:
                owner = mo.group(2).strip() or mo.group(1)
            continue
        ms = re.match(r"^(\s*)\|(\w+):\s*$", l)
        if not ms or ms.group(2) not in SLOTS or ind != 2:
            continue
        o = L[i + 1] if i + 1 < len(L) else ""
        mo = re.match(r"^\s*\\_(\w+):\s*(.*)$", o)
        if not mo:
            continue
        kind = mo.group(1)
        name = mo.group(2).split(",")[0].strip()
        # the object's own vpiNetType, if it prints one
        # The object's OWN attributes sit at ind+2 (the object header is at
        # ind, like its slot).  Scanning deeper would read a CHILD's netType —
        # measured: it reported the inner element net of an array_net.
        nt = "-"
        j = i + 2
        while j < len(L) and (len(L[j]) - len(L[j].lstrip(" "))) > ind:
            t = L[j].strip()
            if (len(L[j]) - len(L[j].lstrip(" "))) == ind + 2 and \
               t.startswith("|vpiNetType:"):
                nt = t.split(":", 1)[1]
                break
            j += 1
        rows.append((sect, owner, ms.group(2), kind, name, nt))
    return rows


def key(r):
    return (r[0], r[1], r[4])


def main():
    fns = sys.argv[1:]
    if os.environ.get("DIFF") and len(fns) == 2:
        g, o = parse(fns[0]), parse(fns[1])
        gk = {}
        ok = {}
        for r in g:
            gk.setdefault(key(r), []).append(r)
        for r in o:
            ok.setdefault(key(r), []).append(r)
        print("    %-16s %-24s %-28s %s" % ("section", "name", "GOLDEN", "OURS"))
        for k in sorted(set(gk) | set(ok)):
            gv = gk.get(k, [])
            ov = ok.get(k, [])
            gs = "; ".join("%s/%s nt=%s" % (r[2], r[3], r[5]) for r in gv) or "<none>"
            os_ = "; ".join("%s/%s nt=%s" % (r[2], r[3], r[5]) for r in ov) or "<none>"
            mark = "  " if gs == os_ else "!!"
            print("%s  %-16s %-24s %-28s %s" % (mark, k[0], k[2], gs, os_))
        return
    for fn in fns:
        print("==", fn)
        for r in parse(fn):
            print("   %-16s %-14s %-14s %-12s %-26s nt=%s" % r)


main()
