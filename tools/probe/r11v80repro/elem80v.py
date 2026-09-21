#!/usr/bin/env python3
"""v11u80 verifier — ELEMENT-LEVEL holder reader.  For every array_var /
array_net top-level slot in a section, print the holder's compared scalars and
then the ELEMENT object's kind, vpiName, vpiNetType, vpiSigned and its actual
typespec kind+name.  Spans are stripped; vpiFullName is never printed."""
import re
import sys

SECT = re.compile(r"^\|(\w+):\s*$")
TOP = re.compile(r"^  \\_(array_var|array_net): \(([^)]*)\)")
WANT = ("vpiSize", "vpiAutomatic", "vpiVisibility", "vpiRandType",
        "vpiArrayType", "vpiNetType", "vpiSigned", "vpiConstantVariable")


def main():
    path = sys.argv[1]
    sect = sys.argv[2]
    L = open(path, encoding="utf8", errors="replace").read().split("\n")
    cur = None
    i = 0
    while i < len(L):
        m = SECT.match(L[i])
        if m:
            cur = m.group(1)
            i += 1
            continue
        m = TOP.match(L[i])
        if m and cur == sect:
            kind, name = m.group(1), m.group(2)
            hf = []
            hts = None
            el = None
            elf = []
            elts = None
            pend = None
            depth_elem = None
            j = i + 1
            while j < len(L):
                ll = L[j]
                if TOP.match(ll) or SECT.match(ll) or (ll and not ll.startswith("    ") and not ll.startswith("  |")):
                    break
                f = re.match(r"^    \|(vpi\w+):(.*)$", ll)
                if f:
                    pend = f.group(1)
                    if f.group(1) in WANT:
                        hf.append(f.group(1)[3:] + "=" + f.group(2).strip())
                    if f.group(1) == "vpiTypespec":
                        a = re.match(r"^    \\_(\w+): ?\(?([^),]*)", L[j + 1] if j + 1 < len(L) else "")
                    j += 1
                    continue
                c = re.match(r"^    \\_(\w+): ?\(?([^),]*)", ll)
                if c:
                    if pend in ("vpiReg", "vpiNet", "vpiVariables", "vpiElement") and el is None:
                        el = c.group(1)
                        depth_elem = j
                    if pend == "vpiTypespec" and hts is None and c.group(1) == "ref_typespec":
                        k = j + 1
                        while k < len(L) and L[k].startswith("      "):
                            if L[k].startswith("      |vpiActual:"):
                                a = re.match(r"^      \\_(\w+): ?(\(([^)]*)\))?", L[k + 1])
                                if a:
                                    hts = a.group(1) + "(" + (a.group(3) or "") + ")"
                                break
                            k += 1
                    pend = None
                j += 1
            if depth_elem is not None:
                k = depth_elem + 1
                pend2 = None
                while k < len(L) and (L[k].startswith("      ") or L[k].startswith("     |")):
                    f = re.match(r"^      \|(vpi\w+):(.*)$", L[k])
                    if f:
                        pend2 = f.group(1)
                        if f.group(1) in ("vpiName", "vpiNetType", "vpiSigned", "vpiSize", "vpiAutomatic"):
                            elf.append(f.group(1)[3:] + "=" + f.group(2).strip())
                    c = re.match(r"^      \\_(\w+): ?\(?([^),]*)", L[k])
                    if c and pend2 == "vpiTypespec" and elts is None:
                        q = k + 1
                        while q < len(L) and L[q].startswith("        "):
                            if L[q].startswith("        |vpiActual:"):
                                a = re.match(r"^        \\_(\w+): ?(\(([^)]*)\))?", L[q + 1])
                                if a:
                                    elts = a.group(1) + "(" + (a.group(3) or "") + ")"
                                break
                            q += 1
                    k += 1
            print("%-26s %-10s %-26s ts=%-26s | elem=%-14s %-34s ts=%s"
                  % (name, kind, " ".join(hf), hts, el, " ".join(elf), elts))
            i = j
            continue
        i += 1


main()
