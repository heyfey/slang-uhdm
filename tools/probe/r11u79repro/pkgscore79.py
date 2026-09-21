#!/usr/bin/env python3
"""r11u79 PACKAGE-SECTION SCORER — one row per entry of a package's own
listing (`vpiVariables` / `vpiNet` / `vpiArrayNet` / `vpiArrayVar`), golden
against ours, with the COMPARED fields beside the kind.

The package section is its own writer: `UhdmWriter::writePackage`
(Surelog src/DesignCompile/UhdmWriter.cpp:1180) hands `p->Variables()` the
package netlist's variables and `p->Nets()` the output of
`writeNets(pack, pack->getSignals(), ..., instance=nullptr)` — the FLAT
def-view writer.  `NetlistElaboration::elaboratePackages` (:100) is what
splits the one signal vector between them: a signal whose `elabSignal`
returns false is ERASED from `getSignals()` and lands in the variables
vector instead.

Fields printed are the ones the judge reads: the object KIND, `vpiNetType`
(net::Compare), `vpiAutomatic` and `vpiVisibility` and
`vpiConstantVariable` (variables::Compare), `vpiSize` (expr::Compare) and,
for an array holder, the ELEMENT object's kind (array_var::Compare reads
Variables(), array_net::Compare reads Nets()).  No span, no fullname.

usage:  pkgscore79.py <gold.dump> <ours.dump> [--all]
        SECT=uhdmallPackages pkgscore79.py ...
"""
import os, re, sys

SLOTS = ("vpiVariables", "vpiNet", "vpiNets", "vpiArrayNet", "vpiArrayNets",
         "vpiArrayVar", "vpiArrayVars")
FIELDS = ("vpiNetType", "vpiAutomatic", "vpiVisibility",
          "vpiConstantVariable", "vpiSize", "vpiConstType")


def ind(l):
    return len(l) - len(l.lstrip(" "))


def parse(fn):
    L = open(fn, errors="replace").read().splitlines()
    sect, owner, rows = "?", "?", []
    for i, l in enumerate(L):
        m = re.match(r"^\|(uhdm\w+|weaklyReferenced\w*):", l)
        if m:
            sect = m.group(1)
            continue
        if ind(l) == 0 and l.startswith("\\_"):
            mo = re.match(r"^\\_(\w+):\s*([^,]*)", l)
            owner = (mo.group(2).strip() or mo.group(1)) if mo else owner
            continue
        ms = re.match(r"^(\s*)\|(\w+):\s*$", l)
        if not ms or ms.group(2) not in SLOTS or ind(l) != 2:
            continue
        o = L[i + 1] if i + 1 < len(L) else ""
        mo = re.match(r"^\s*\\_(\w+):\s*(.*)$", o)
        if not mo:
            continue
        kind = mo.group(1)
        name = mo.group(2).split(",")[0].strip()
        own, elem = {}, "-"
        j = i + 2
        while j < len(L) and ind(L[j]) > 2:
            t = L[j].strip()
            if ind(L[j]) == 4:
                for f in FIELDS:
                    if t.startswith("|" + f + ":"):
                        own[f] = t.split(":", 1)[1]
                # the element object of an array holder: the child under the
                # holder's own vpiVariables/vpiNet slot
                if t in ("|vpiVariables:", "|vpiNet:", "|vpiNets:", "|vpiReg:"):
                    n = L[j + 1] if j + 1 < len(L) else ""
                    me = re.match(r"^\s*\\_(\w+):", n)
                    if me:
                        elem = me.group(1)
            j += 1
        rows.append((sect, owner, ms.group(2), kind, name, own, elem))
    return rows


def face(r):
    _, _, slot, kind, _, own, elem = r
    s = "%s/%s" % (slot, kind)
    for f in FIELDS:
        if f in own:
            s += " %s=%s" % (f.replace("vpi", "").lower()[:4], own[f])
    if elem != "-":
        s += " elem=%s" % elem
    return s


def main():
    g, o = parse(sys.argv[1]), parse(sys.argv[2])
    want = os.environ.get("SECT", "Packages")
    allrows = "--all" in sys.argv[3:]
    gk, ok = {}, {}
    for r in g:
        if want in r[0]:
            gk.setdefault((r[0], r[4]), []).append(r)
    for r in o:
        if want in r[0]:
            ok.setdefault((r[0], r[4]), []).append(r)
    bad = 0
    print("    %-17s %-22s %-40s %s" % ("section", "name", "GOLDEN", "OURS"))
    for k in sorted(set(gk) | set(ok)):
        gs = "; ".join(face(r) for r in gk.get(k, [])) or "<none>"
        os_ = "; ".join(face(r) for r in ok.get(k, [])) or "<none>"
        if gs == os_:
            if not allrows:
                continue
            mark = "  "
        else:
            mark = "!!"
            bad += 1
        print("%s  %-17s %-22s %-40s %s" % (mark, k[0], k[1], gs, os_))
    print("PKGROWS gold=%d ours=%d MISMATCH=%d" %
          (sum(len(v) for v in gk.values()), sum(len(v) for v in ok.values()),
           bad))


main()
