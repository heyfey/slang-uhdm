#!/usr/bin/env python3
"""r10ladder1/genfields.py -- extract the OFFICIAL Compare field order per kind.

ctladder must name the FIRST DIFFERING FIELD of a failing pair.  Reading the
fields in some order of my own invention would answer a different question than
the one the judge asks, so the order is not invented here: it is READ OUT of
UHDM's own generated `<kind>::Compare` bodies, in source order, with the base
class's fields spliced in at the exact point `basetype_t::Compare` is called.

Three field shapes exist in those bodies and all three are captured:
    TYPE   `VpiType() - other->VpiType()`               (kind mismatch)
    PROP   `lhs->VpiXxx() ... rhs->VpiXxx()`            (scalar property)
    REL1   `SafeCompare(lhs->Yyy(), rhs->Yyy(), ...)`   (single child)
    RELV   `SafeCompare(lhs, lhs->Yyy(), rhs, rhs->Yyy(), ...)` (child vector)

Each field is then given the vpi SELECTOR int that reads it back at runtime,
scraped from the same file's `GetVpiPropertyValue` / `GetByVpiType` switch.  A
field with NO selector is emitted with selector 0 and marked UNREADABLE rather
than dropped -- a silently dropped field would make ctladder report
"no differing field" for a pair that differs in exactly that field, which is
the single most dangerous failure mode this instrument has.

usage: genfields.py <uhdm-generated-src-dir> <uhdm-include-dir> > ctfields.inc
"""
import os
import re
import sys


def vpi_consts(incdir):
    """name -> int, from the three installed vpi headers."""
    out = {}
    for f in ("vpi_user.h", "sv_vpi_user.h", "uhdm_vpi_user.h"):
        p = os.path.join(incdir, f)
        if not os.path.exists(p):
            sys.exit("FATAL: missing %s" % p)
        for line in open(p):
            m = re.match(r"^#define\s+(vpi[A-Za-z0-9_]*)\s+(\d+)", line)
            if m:
                out.setdefault(m.group(1), int(m.group(2)))
    return out


def parents(incdir):
    """kind -> immediate base, from class_hierarchy.txt's indentation tree."""
    p = os.path.join(incdir, "class_hierarchy.txt")
    if not os.path.exists(p):
        sys.exit("FATAL: missing %s" % p)
    stack, out = [], {}
    for line in open(p):
        if not line.strip():
            continue
        depth = (len(line) - len(line.lstrip(" "))) // 2
        name = line.strip()
        stack[depth:] = [name]
        if depth:
            out[name] = stack[depth - 1]
    return out


def body(src, sig):
    i = src.find(sig)
    if i < 0:
        return None
    j = src.find("\n}", i)
    return src[i:j]


def parse_kind(path):
    src = open(path).read()
    kind = os.path.basename(path)[:-4]
    # --- selector maps -------------------------------------------------
    prop_sel, rel_sel = {}, {}
    b = body(src, "%s::GetVpiPropertyValue(" % kind)
    if b:
        for cs, acc in re.findall(
            r"case\s+(vpi\w+):[^;{]*(?:\{)?[^;]*?\b(Vpi\w+)\(\)", b):
            prop_sel.setdefault(acc, cs)
    b = body(src, "%s::GetByVpiType(" % kind)
    if b:
        for cs, args in re.findall(r"case\s+(vpi\w+):\s*return std::make_tuple\(([^;]*)\);", b):
            m = re.search(r"(\w+)_\s*\)\s*$", args) or re.search(r"\b(\w+)_\b", args)
            if m:
                rel_sel.setdefault(m.group(1)[0].upper() + m.group(1)[1:], cs)
    # --- compare order -------------------------------------------------
    b = body(src, "int32_t %s::Compare(" % kind)
    fields = []
    if b is None:
        return kind, None, prop_sel, rel_sel
    for line in b.split("\n"):
        if "VpiType() - other->VpiType()" in line or "VpiType() - rhs->VpiType()" in line:
            fields.append(("VpiType", "TYPE"))
        elif "basetype_t::Compare" in line:
            fields.append(("", "BASE"))
        elif "SafeCompare(lhs, lhs->" in line:
            m = re.search(r"SafeCompare\(lhs, lhs->(\w+)\(\)", line)
            if m:
                fields.append((m.group(1), "RELV"))
        elif "SafeCompare(lhs->" in line:
            m = re.search(r"SafeCompare\(lhs->(\w+)\(\)", line)
            if m:
                fields.append((m.group(1), "REL1"))
        else:
            # BaseClass::Compare writes the bare `VpiName().compare(rhs->...)`
            # form while the generated kinds write `lhs->VpiName()`; matching
            # only the `lhs->` form SILENTLY DROPPED VpiName/VpiDefName from
            # every kind's inherited prefix.  Both forms name the field on the
            # rhs side, so that is what is matched.
            m = re.search(r"rhs->(Vpi\w+)\(\)", line)
            if m:
                fields.append((m.group(1), "PROP"))
    return kind, fields, prop_sel, rel_sel


def main():
    gendir, incdir = sys.argv[1], sys.argv[2]
    consts = vpi_consts(incdir)
    par = parents(incdir)
    raw, psel, rsel = {}, {}, {}
    for f in sorted(os.listdir(gendir)):
        if not f.endswith(".cpp"):
            continue
        k, fl, ps, rs = parse_kind(os.path.join(gendir, f))
        if fl is not None:
            raw[k] = fl
        psel[k], rsel[k] = ps, rs

    def sel_for(kind, acc, shape):
        k = kind
        while k:
            m = psel.get(k, {}) if shape == "PROP" else rsel.get(k, {})
            if acc in m:
                return m[acc]
            k = par.get(k)
        return None

    def flat(kind, depth=0):
        if depth > 12 or kind not in raw:
            return []
        out = []
        for acc, shape in raw[kind]:
            if shape == "BASE":
                out += flat(par.get(kind, ""), depth + 1)
            else:
                out.append((acc, shape, kind))
        return out

    # BaseClass::Compare lives in the hand-written template, not a per-kind file
    raw.setdefault("BaseClass", [("VpiType", "TYPE"), ("VpiName", "PROP"),
                                 ("VpiDefName", "PROP")])
    unreadable = 0
    print("// GENERATED by genfields.py -- do not hand-edit.")
    print("// %d kinds; field order taken verbatim from the generated Compare bodies." % len(raw))
    for kind in sorted(raw):
        fl = flat(kind)
        seen, uniq = set(), []
        for acc, shape, owner in fl:
            if (acc, shape) in seen:
                continue
            seen.add((acc, shape))
            uniq.append((acc, shape, owner))
        print('{"%s", {' % kind)
        for acc, shape, owner in uniq:
            if shape == "TYPE":
                print('  {"VpiType", 0, F_TYPE},')
                continue
            cs = sel_for(kind, acc, "PROP" if shape == "PROP" else "REL")
            n = consts.get(cs, 0) if cs else 0
            if not n:
                unreadable += 1
            print('  {"%s", %d, F_%s},%s' % (acc, n, shape, "" if n else "  // UNREADABLE"))
        print("}},")
    print("// UNREADABLE fields (no vpi selector in GetVpiPropertyValue/GetByVpiType): %d"
          % unreadable, file=sys.stderr)


main()
