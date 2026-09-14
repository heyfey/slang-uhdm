#!/usr/bin/env python3
"""L1 a-priori mover prediction for § typeParamDefaultBoundNoReduce20.

SOURCE-keyed, because nothing in a database records "this bound was WRITTEN
symbolically": a row moves iff one of its sources declares a `parameter type` /
`localparam type` whose DEFAULT carries a packed range with a bound that is not
a plain integer literal.  A literal-only default (`logic [7:0]`) is a no-op —
it already agrees with golden — and a typedef-named or overridden default takes
no range of its own here.

Declarations span lines, so the scan is over the whole file text.

usage: predL1_20.py <corpus-root> [<depth>]
   depth 1 (default) prints the first path component under the root, which is
   the uhdm2rtlil row name; depth 0 prints the file path (the Surelog corpus,
   whose row names come from its `.sl` files).
"""
import os, re, sys

DECL = re.compile(
    r'\b(?:parameter|localparam)\s+type\s+([^;)]*?)'
    r'(?=;|\)|\bparameter\b|\blocalparam\b)', re.S)
RANGE = re.compile(r'\[([^\]]*)\]')


def main():
    root = sys.argv[1]
    depth = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    hits = set()
    for dp, _dirs, fs in os.walk(root):
        for fn in fs:
            if not fn.endswith(('.sv', '.v', '.svh', '.vh')):
                continue
            p = os.path.join(dp, fn)
            try:
                t = open(p, errors='replace').read()
            except Exception:
                continue
            for m in DECL.finditer(t):
                for r in RANGE.finditer(m.group(1)):
                    if re.search(r'[A-Za-z_$]', r.group(1)):
                        rel = os.path.relpath(p, root)
                        hits.add(rel.split('/')[0] if depth else rel)
                        break
    for h in sorted(hits):
        print(h)


main()
