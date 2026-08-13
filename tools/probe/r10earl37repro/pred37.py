#!/usr/bin/env python3
"""r10earl37 — the SOURCE-DERIVED MOVER FENCE.

§ genConnDottedActualIsHierPath37 can reach exactly one thing: a NAMED port
connection, written inside a GENERATE BLOCK (call site 1) or on a MODULE ARRAY
(call site 2), whose actual's TEXT contains a `.` and no `::`-only form, i.e.
a `ScopedName` with a dot separator.  Nothing else in either emitter changes.

This script enumerates that set from the corpus SOURCE, so the mover count is
predicted BEFORE the patched sweep runs rather than pattern-matched after it.

The enumeration is deliberately OVER-broad — it does not resolve scopes, so it
counts `.a.b` actuals that turn out to be hierarchical, interface or modport
reads too (all of which the grid measured as the SAME hier_path answer).  An
over-broad fence is the safe direction: any mover OUTSIDE it is a defect.

usage: pred37.py <root-dir> [...]
"""
import os
import re
import sys

# `.formal(actual)` on one line — the only form either emitter reads, since
# both key on NamedPortConnectionSyntax.
CONN = re.compile(r'\.\s*([A-Za-z_][A-Za-z_0-9$]*)\s*\(\s*([^()]*?)\s*\)\s*[,)]')
# A dotted path actual: ident(.ident|[..])+ with at least one dot, no operators.
DOTTED = re.compile(r'^[A-Za-z_][A-Za-z_0-9$]*'
                    r'(?:\s*\[[^\]]*\])*'
                    r'(?:\s*\.\s*[A-Za-z_][A-Za-z_0-9$]*(?:\s*\[[^\]]*\])*)+$')
GENOPEN = re.compile(r'\b(?:generate|for\s*\(\s*genvar|if\s*\(|begin)\b')


def scan(path):
    """-> list of (file, line, formal, actual, in_generate_guess)."""
    hits = []
    try:
        with open(path, 'rt', errors='replace') as f:
            src = f.read()
    except OSError:
        return hits
    # Track a crude generate depth: a `generate` / `for (genvar` / a labelled
    # `begin :` opens one.  This is a REPORTING aid only — the fence itself is
    # the dotted-actual set, which is a superset of both call sites.
    lines = src.split('\n')
    gen = 0
    for i, ln in enumerate(lines, 1):
        bare = ln.split('//')[0]
        if re.search(r'\bfor\s*\(\s*genvar\b', bare) or \
           re.search(r'^\s*generate\b', bare):
            gen += 1
        if re.search(r'^\s*endgenerate\b', bare):
            gen = max(0, gen - 1)
        for m in CONN.finditer(bare):
            act = m.group(2).strip()
            if not act or '::' in act.split('.')[0] and '.' not in act:
                continue
            if '.' not in act:
                continue
            if not DOTTED.match(act):
                continue
            hits.append((path, i, m.group(1), act, gen > 0))
    return hits


def main():
    tot = 0
    for root in sys.argv[1:]:
        for dirpath, _d, files in os.walk(root):
            for fn in files:
                if not fn.endswith(('.sv', '.v', '.svh')):
                    continue
                for h in scan(os.path.join(dirpath, fn)):
                    print('%s:%d  .%s(%s)%s' %
                          (os.path.relpath(h[0], root), h[1], h[2], h[3],
                           '   [in generate]' if h[4] else ''))
                    tot += 1
    print('TOTAL dotted named-conn actuals: %d' % tot)


main()
