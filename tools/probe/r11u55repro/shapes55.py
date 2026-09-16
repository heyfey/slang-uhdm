#!/usr/bin/env python3
"""r11u55 SHAPE LISTER + A-PRIORI MOVER CENSUS for ROAD E.

Road E's fix widens the ELABORATED cont_assign's share decision, and ~40 test
directories in the two corpora declare a struct-typed parameter and read a
dotted name on a continuous assignment.  This lister enumerates them BY NAME
and, for each, prints the SHAPE of every candidate site so the pass can predict
move-or-stay per row BEFORE the sweep.

It is a SOURCE-TEXT lister on purpose: it must name rows the pass has not built
databases for, and it must over-approximate (a row it lists and that does not
move is harmless; a row it misses is the regression nobody predicted).

POSITIVE CONTROL: `--selftest` runs the lister over this pass's own grid arms,
whose shapes are known cell by cell, and asserts the expected classes appear.
A census with no positive control is a census that can silently return zero.

shape classes (what the fix is keyed on):
  PARAM_STRUCT   a parameter/localparam whose declared type is a user type and
                 whose default is, or reaches, an assignment pattern
  CA_DOT         a continuous assign whose Rhs contains `NAME.NAME`
  CA_DOT_PARAM   a CA_DOT whose dotted base is one of this file's parameters
  CA_DOT_GEN     a CA_DOT inside a generate block
  CA_DOT_CAT     a CA_DOT inside a concatenation
  CA_DOT_SEL     a CA_DOT under a bit/part select
  CA_DOT_DEEP    a two-or-more-level dotted read (A.b.c)
  CA_DOT_IDX     a dotted read whose base is indexed (A[0].n)
usage: shapes55.py [--selftest] [roots...]
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

# a parameter/localparam declared with a NON-builtin (user) type
PARAM_TYPED = re.compile(
    r'\b(?:parameter|localparam)\s+(?:type\s+)?'
    r'((?:[A-Za-z_]\w*\s*::\s*)?[A-Za-z_]\w*)\s+([A-Za-z_]\w*)\s*(?:\[[^\]]*\]\s*)*=')
BUILTIN = {
    "logic", "bit", "int", "integer", "reg", "wire", "byte", "shortint",
    "longint", "time", "real", "shortreal", "realtime", "string", "signed",
    "unsigned", "type", "chandle", "event", "void",
}
CA = re.compile(r'^\s*assign\b(.*?);', re.S | re.M)
DOT = re.compile(r'\b([A-Za-z_]\w*)((?:\s*\[[^\]]*\])*)\s*\.\s*([A-Za-z_]\w*)'
                 r'((?:\s*\.\s*[A-Za-z_]\w*)*)')


def scan_file(path):
    try:
        txt = open(path, errors="replace").read()
    except OSError:
        return None
    # strip line comments so a commented `assign a = B.c;` never counts
    txt = re.sub(r'//[^\n]*', '', txt)
    params = {}
    for m in PARAM_TYPED.finditer(txt):
        ty = re.sub(r'\s+', '', m.group(1))
        base = ty.split("::")[-1]
        if base in BUILTIN:
            continue
        params[m.group(2)] = ty
    hits = []
    # A cont_assign is in a GENERATE scope exactly when it sits inside a
    # `begin`/`end` (or a `generate`/`endgenerate`) at module level: a
    # continuous assign cannot appear in any other block.  Depth-counted
    # rather than span-matched, because begin/end nest.
    depth = 0
    gendepth = {}
    for m in re.finditer(r'\b(generate|begin|end|endgenerate|endmodule)\b', txt):
        w = m.group(1)
        gendepth[m.start()] = depth
        if w in ("generate", "begin"):
            depth += 1
        elif w in ("end", "endgenerate") and depth > 0:
            depth -= 1
        elif w == "endmodule":
            depth = 0
    marks = sorted(gendepth.items())

    def in_gen(pos):
        d = 0
        for p, dd in marks:
            if p > pos:
                break
            d = dd + (1 if txt[p:p + 5] in ("gener", "begin") else
                      (-1 if dd > 0 else 0))
        return d > 0
    for cm in CA.finditer(txt):
        body = cm.group(1)
        if "=" not in body:
            continue
        rhs = body.split("=", 1)[1]
        for dm in DOT.finditer(rhs):
            base, idx, first, rest = dm.groups()
            cls = ["CA_DOT"]
            if base in params:
                cls.append("CA_DOT_PARAM")
            if idx.strip():
                cls.append("CA_DOT_IDX")
            if rest.strip():
                cls.append("CA_DOT_DEEP")
            if "{" in rhs[:dm.start()]:
                cls.append("CA_DOT_CAT")
            tail = rhs[dm.end():dm.end() + 3]
            if tail.lstrip().startswith("["):
                cls.append("CA_DOT_SEL")
            if in_gen(cm.start()):
                cls.append("CA_DOT_GEN")
            hits.append((base, idx.strip(), first + rest,
                         params.get(base, "-"), "+".join(cls)))
    return params, hits


def walk(roots):
    rows = {}
    for root in roots:
        if not os.path.isdir(root):
            continue
        for d in sorted(os.listdir(root)):
            dp = os.path.join(root, d)
            if not os.path.isdir(dp):
                continue
            allp, allh = {}, []
            for base, _, files in os.walk(dp):
                if "slpp_all" in base or "slpp_unit" in base:
                    continue
                for f in files:
                    if not f.endswith(SRC_EXT):
                        continue
                    r = scan_file(os.path.join(base, f))
                    if not r:
                        continue
                    allp.update(r[0])
                    allh.extend(r[1])
            if allp and allh:
                pin = [h for h in allh if "CA_DOT_PARAM" in h[4]]
                if pin:
                    rows[(root, d)] = (allp, pin)
    return rows


def main():
    selftest = "--selftest" in sys.argv
    if selftest:
        here = os.path.dirname(os.path.abspath(__file__))
        rows = walk([os.path.join(here, "grid")])
        seen = set()
        for _, (_, hits) in rows.items():
            for h in hits:
                seen.update(h[4].split("+"))
        need = {"CA_DOT", "CA_DOT_PARAM", "CA_DOT_DEEP", "CA_DOT_IDX",
                "CA_DOT_CAT", "CA_DOT_SEL", "CA_DOT_GEN"}
        print("SELFTEST dirs=%d classes=%s" % (len(rows), ",".join(sorted(seen))))
        missing = need - seen
        print("SELFTEST %s missing=%s"
              % ("PASS" if not missing else "FAIL", ",".join(sorted(missing)) or "-"))
        return 0 if not missing else 5
    rows = walk(sys.argv[1:] or ROOTS)
    print("# ROAD-E BOUNDARY: dirs whose cont_assign Rhs reads a dotted name"
          " off a USER-TYPED parameter declared in the same dir")
    for (root, d), (params, hits) in sorted(rows.items(), key=lambda x: x[0][1]):
        corp = "u2r" if "uhdm2rtlil" in root else (
            "sl3p" if "third_party" in root else "sl")
        cls = set()
        for h in hits:
            cls.update(h[4].split("+"))
        print("%-5s %-42s sites=%-3d %s" % (corp, d, len(hits),
                                            ",".join(sorted(cls))))
        for h in sorted(set(hits)):
            print("        %s%s.%s  type=%s  [%s]" % (h[0], h[1], h[2], h[3], h[4]))
    print("# TOTAL DIRS: %d" % len(rows))
    return 0


if __name__ == "__main__":
    sys.exit(main())
