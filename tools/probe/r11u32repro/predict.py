#!/usr/bin/env python3
"""r11u32 — A-PRIORI mover prediction, from the SOURCES, before the patched
sweep runs.  Never reads a patched database.

THE TWO LAWS AND THEIR SOURCE SHAPES
  Law A (§ namedTypeLeafNoNetType32, DEF vpiNetType): a declaration whose
        written data type is a NAME carrying PACKED dims, where that name is a
        `parameter type` or an `enum` typedef.  (The dimension-less cells were
        already right, so only the dimensioned spelling can move.)
  Law B (§ namedTypePackedDimElabVar32, ELAB object kind): the same shape with
        the name a `parameter type` whose binding is a LOGIC VECTOR.
So: a design can move iff one of its sources declares `parameter type N` or
`typedef enum ... N;` AND spells `N [ ... ] <id>` somewhere.

This over-predicts on purpose (it cannot resolve scopes or bindings and it
counts a `pkg::N [..] x` spelling too).  Over-prediction is the safe direction:
a mover NOT on this list is an unexplained mover and fails the pass.

usage: predict.py <corpus-root> [<corpus-root> ...]
"""
import os, re, sys

TYPEPARAM = re.compile(r'\bparameter\s+type\s+(\w+)')
ENUMTD    = re.compile(r'\btypedef\s+enum\b[^;]*?\b(\w+)\s*;', re.S)
DIMUSE    = re.compile(r'(?<![\w.])(\w+)\s*\[[^\];]*\]\s+\w+\s*(?:;|,|\)|\[)')

SRC_EXT = ('.sv', '.v', '.svh', '.vh')

def scan_dir(d):
    names, uses = set(), set()
    for root, _, files in os.walk(d):
        for f in files:
            if not f.endswith(SRC_EXT):
                continue
            try:
                txt = open(os.path.join(root, f), errors='replace').read()
            except OSError:
                continue
            for m in TYPEPARAM.finditer(txt):
                names.add(m.group(1))
            for m in ENUMTD.finditer(txt):
                names.add(m.group(1))
            for m in DIMUSE.finditer(txt):
                uses.add(m.group(1))
    return names & uses

def main():
    hits = {}
    for rootdir in sys.argv[1:]:
        for name in sorted(os.listdir(rootdir)):
            d = os.path.join(rootdir, name)
            if not os.path.isdir(d):
                continue
            h = scan_dir(d)
            if h:
                hits[name] = sorted(h)
    for k, v in sorted(hits.items()):
        print(f'{k}\t{",".join(v)}')
    print(f'-- PREDICTED CANDIDATES: {len(hits)}')

main()
