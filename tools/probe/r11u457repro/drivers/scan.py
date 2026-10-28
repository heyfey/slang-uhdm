#!/usr/bin/env python3
# scan.py <file>...: print files holding a function whose body is a single
# `return <integer literal>;` or `return <name> + <name|literal>;` (the callee
# shapes of §§ 300/457), with the matching function names.
import re, sys
pat = re.compile(r'\bfunction\b([^;]*?)\b(\w+)\s*(\([^;]*?\))?\s*;\s*(?://[^\n]*\n\s*)*return\s+([^;]+);\s*endfunction', re.S)
lit = re.compile(r"^\s*(\d[\d_]*)?\s*('s?[dD]\s*)?[\d_]+\s*$")
add = re.compile(r"^\s*\w+\s*(\+\s*(\w+|\d[\d_]*))?\s*$")
for f in sys.argv[1:]:
    try: t = open(f, errors='replace').read()
    except Exception: continue
    hits = []
    for m in pat.finditer(t):
        e = m.group(4)
        if lit.match(e) or add.match(e):
            hits.append(m.group(2) + ':' + e.strip())
    if hits:
        print(f, ' '.join(hits[:6]), len(hits))
