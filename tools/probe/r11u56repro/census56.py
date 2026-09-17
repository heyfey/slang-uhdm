#!/usr/bin/env python3
"""r11u56 A-PRIORI MOVER CENSUS + SHAPE LISTER for the substituted leaf's
ENCODING.

The encoding law can only fire where § caStructParamPatternSubst55 already
substitutes: a continuous assign whose Rhs is a dotted read off a STRUCT-TYPED
parameter (that is `shapes55.py`'s CA_DOT_PARAM boundary).  Inside that
boundary it fires only for a member whose PATTERN SETTER is

  UNSIZED   an unbased-unsized fill (`'1`, `'0`, `'x`, `'z`)         -> face F3
  INTISH    a unary minus, or an arithmetic form the reduce table
            answers `vpiIntConst` for (`-`, `*`, `/`, `%`, `**`)     -> face F1
  ENUMNAME  a bare identifier that the dir declares as an ENUM member -> face F1

and it ABSTAINS on

  BASED     a based literal (`16'hBEEF`, `16'd40`, and a NAME reaching one)
  PLAIN     a plain decimal, an add, a shift, a `$` call

This is a SOURCE-TEXT lister on purpose: it must name rows before any database
exists and must OVER-approximate — it never asks whether the member is actually
read, so the measured movers must be a SUBSET of what it prints.

POSITIVE CONTROL: `--selftest` runs it over this pass's own grid arms, whose
setter kinds are known cell by cell, and asserts that e1/e2/e4 are named with
the UNSIZED/INTISH/ENUMNAME classes and that e3 (the base-letter fence) carries
BASED only.  A census with no positive control can silently return zero.

usage: census56.py [--selftest] [roots...]
"""
import os
import re
import sys

HOME = os.path.expanduser("~")
ROOTS = [
    os.path.join(HOME, "git-repos", "uhdm2rtlil", "test"),
    os.path.join(HOME, "git-repos", "Surelog", "tests"),
    os.path.join(HOME, "git-repos", "Surelog", "third_party", "tests"),
]
SRC_EXT = (".sv", ".v", ".svh", ".vh")

PARAM_TYPED = re.compile(
    r'\b(?:parameter|localparam)\s+(?:type\s+)?'
    r'((?:[A-Za-z_]\w*\s*::\s*)?[A-Za-z_]\w*)\s+([A-Za-z_]\w*)\s*(?:\[[^\]]*\]\s*)*=')
BUILTIN = {
    "logic", "bit", "int", "integer", "reg", "wire", "byte", "shortint",
    "longint", "time", "real", "shortreal", "realtime", "string", "signed",
    "unsigned", "type", "chandle", "event", "void",
}
CA = re.compile(r'^\s*assign\b(.*?);', re.S | re.M)
DOT = re.compile(r'\b([A-Za-z_]\w*)((?:\s*\[[^\]]*\])*)\s*\.\s*([A-Za-z_]\w*)')
# `'{ name : value , ... }` — one named setter per match, value up to the next
# top-level comma or the closing brace (nested braces/parens are skipped).
PATTERN = re.compile(r"'\{")
ENUMDECL = re.compile(r'\benum\b[^;{]*\{([^}]*)\}', re.S)
BASEDLIT = re.compile(r"\b\d*\s*'\s*[sS]?\s*[hHoObBdD]\s*[0-9a-fA-FxXzZ_]+")
UNSIZED = re.compile(r"'\s*[01xXzZ]\s*(?![0-9a-zA-Z_'])")
INTISH = re.compile(r'(^\s*-)|[*/%]|\*\*')


def split_setters(txt, start):
    """Return [(name, value)] of the `'{...}` starting at `start` (the quote)."""
    i = txt.find('{', start)
    if i < 0:
        return []
    depth = 0
    body_start = i + 1
    j = i
    while j < len(txt):
        c = txt[j]
        if c in '{([':
            depth += 1
        elif c in '})]':
            depth -= 1
            if depth == 0:
                break
        j += 1
    body = txt[body_start:j]
    out = []
    depth = 0
    cur = ''
    parts = []
    for c in body:
        if c in '{([':
            depth += 1
        elif c in '})]':
            depth -= 1
        if c == ',' and depth == 0:
            parts.append(cur)
            cur = ''
        else:
            cur += c
    parts.append(cur)
    for p in parts:
        if ':' in p:
            n, v = p.split(':', 1)
            out.append((n.strip(), v.strip()))
        else:
            out.append(('<positional>', p.strip()))
    return out


def classify(value, enum_members, named_params):
    """The face this setter would take, as the law's own predicates see it."""
    v = value.strip()
    if not v:
        return None
    if UNSIZED.match(v) or UNSIZED.fullmatch(v):
        return "UNSIZED"
    if BASEDLIT.search(v) and not v.startswith('-'):
        return "BASED"
    if re.fullmatch(r'[A-Za-z_]\w*', v):
        if v in enum_members:
            return "ENUMNAME"
        if v in named_params:
            return "PLAIN"        # a NAME hop: the table follows its own init
        return "PLAIN"
    if INTISH.search(v):
        return "INTISH"
    return "PLAIN"


def scan_dir(dp):
    params, enum_members, hits, setters = {}, set(), [], []
    for base, _, files in os.walk(dp):
        if "slpp_all" in base or "slpp_unit" in base:
            continue
        for f in files:
            if not f.endswith(SRC_EXT):
                continue
            try:
                txt = open(os.path.join(base, f), errors="replace").read()
            except OSError:
                continue
            txt = re.sub(r'//[^\n]*', '', txt)
            for m in PARAM_TYPED.finditer(txt):
                ty = re.sub(r'\s+', '', m.group(1))
                if ty.split("::")[-1] in BUILTIN:
                    continue
                params[m.group(2)] = ty
            for em in ENUMDECL.finditer(txt):
                for e in em.group(1).split(','):
                    nm = e.split('=')[0].strip()
                    if re.fullmatch(r'[A-Za-z_]\w*', nm):
                        enum_members.add(nm)
            for cm in CA.finditer(txt):
                body = cm.group(1)
                if "=" not in body:
                    continue
                for dm in DOT.finditer(body.split("=", 1)[1]):
                    if dm.group(1) in params:
                        hits.append((dm.group(1), dm.group(3)))
            for pm in PATTERN.finditer(txt):
                setters.extend(split_setters(txt, pm.start()))
    if not hits:
        return None
    classes = {}
    for n, v in setters:
        c = classify(v, enum_members, params)
        if c:
            classes.setdefault(c, []).append((n, v))
    return params, hits, classes


def walk(roots):
    rows = {}
    for root in roots:
        if not os.path.isdir(root):
            continue
        for d in sorted(os.listdir(root)):
            dp = os.path.join(root, d)
            if not os.path.isdir(dp):
                continue
            r = scan_dir(dp)
            if r:
                rows[(root, d)] = r
    return rows


FIRE = ("UNSIZED", "INTISH", "ENUMNAME")


def main():
    if "--selftest" in sys.argv:
        # r11v56: the arms live one level down, in `grid/`.  `walk` lists the
        # CHILDREN of each root it is given, so pointing it at the repro dir
        # itself made every arm invisible and the control printed FAIL.
        here = os.path.dirname(os.path.abspath(__file__))
        rows = walk([os.path.join(here, "grid")])
        seen = {}
        for (_, d), (_, _, cls) in rows.items():
            seen[d] = set(cls)
        ok = True
        for arm, need in (("e1_enc56", {"UNSIZED", "INTISH"}),
                          ("e2_width56", {"UNSIZED", "INTISH", "ENUMNAME"}),
                          ("e4_share56", {"UNSIZED", "INTISH", "ENUMNAME"})):
            got = seen.get(arm, set())
            print("SELFTEST %-12s classes=%s" % (arm, ",".join(sorted(got)) or "-"))
            if not need <= got:
                ok = False
                print("SELFTEST  MISSING %s" % ",".join(sorted(need - got)))
        e3 = seen.get("e3_base56", set())
        print("SELFTEST %-12s classes=%s" % ("e3_base56", ",".join(sorted(e3)) or "-"))
        if e3 & set(FIRE):
            ok = False
            print("SELFTEST  e3 must be BASED/PLAIN only")
        print("SELFTEST %s" % ("PASS" if ok else "FAIL"))
        return 0 if ok else 5
    rows = walk(sys.argv[1:] or ROOTS)
    print("# SHAPE LISTER: every dir inside the CA_DOT_PARAM boundary, with the"
          " setter classes its patterns carry")
    fire = 0
    for (root, d), (params, hits, cls) in sorted(rows.items(), key=lambda x: x[0][1]):
        corp = "u2r" if "uhdm2rtlil" in root else (
            "sl3p" if "third_party" in root else "sl")
        f = [c for c in FIRE if c in cls]
        if f:
            fire += 1
        print("%-5s %-44s dotted=%-3d classes=%-28s %s"
              % (corp, d, len(hits), ",".join(sorted(cls)) or "-",
                 "CANDIDATE:" + "+".join(f) if f else "abstain-only"))
        for c in f:
            for n, v in cls[c][:6]:
                print("        %-9s %s: %s" % (c, n, v[:60]))
    print("# TOTAL DIRS IN BOUNDARY: %d ; CANDIDATE DIRS: %d" % (len(rows), fire))
    return 0


if __name__ == "__main__":
    sys.exit(main())
