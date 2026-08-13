#!/usr/bin/env python3
"""r10sd1 — SPAN-KEYED VECTOR CENSUS of one collection under one named object.

The r10uvm52-era law: `RHS: <null>` names a SLOT, so before theorizing about
which object is missing you must census the PARENT VECTOR on BOTH sides,
span-keyed, and read OUR side out of the census rather than out of a hypothesis.

    usage: census.py <dump> <root-regex> <label> [--kind K]

`<root-regex>` selects the top-level (`\\_` at column 0) object whose section is
walked; `<label>` is the field label whose immediate children are listed
(e.g. `vpiTypespec`).  Output: one line per element, `<kind> <name> <span>`,
in vector order, then a count.

GUARDS (each one an ops trap this campaign has paid for):
  * a root-regex matching ZERO sections is a hard error (exit 4) -- a census that
    reached nothing prints "0 elements" exactly like a real deficit.
  * a root-regex matching MORE THAN ONE top-level section prints EVERY match
    separately and says so: the SeqDriver dump carries the def view AND the elab
    view of `work@top_tb` at column 0 and censusing "the" module silently picks
    one of them.
  * indentation is read from the raw line, and only children at EXACTLY
    root_indent+2 are counted, so a nested `|vpiTypespec:` deeper in the subtree
    can never inflate the count.
"""
import re
import sys

def sections(lines):
    """Yield (start, end) of each column-0 `\\_` top-level object section."""
    idx = [i for i, l in enumerate(lines) if l.startswith('\\_')]
    for n, i in enumerate(idx):
        yield i, (idx[n + 1] if n + 1 < len(idx) else len(lines))

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): ?(.*)$')
LBL = re.compile(r'^(\s*)\|([A-Za-z0-9_]+):(.*)$')

def desc(body):
    """(name, span) out of a dump object's trailing description."""
    m = re.match(r'^(?:\(([^)]*)\)|([^,]*?)\s*\(([^)]*)\))?\s*,?\s*(.*)$', body)
    name = ''
    if m:
        name = m.group(1) or m.group(3) or ''
    sp = ''
    ml = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', body)
    if ml:
        sp = '%s:%s-%s:%s' % ml.groups()
    fm = re.search(r'file:([^,]+)', body)
    f = fm.group(1).split('/')[-1] if fm else ''
    return name, (f + '@' + sp if f else sp)

def main():
    dump, rootre, label = sys.argv[1], sys.argv[2], sys.argv[3]
    kind = None
    if '--kind' in sys.argv:
        kind = sys.argv[sys.argv.index('--kind') + 1]
    lines = open(dump, errors='replace').read().split('\n')
    rx = re.compile(rootre)
    hits = [(a, b) for a, b in sections(lines) if rx.search(lines[a])]
    if not hits:
        print('FATAL: root-regex matched NO column-0 section', file=sys.stderr)
        sys.exit(4)
    print('root sections matched: %d (each censused separately below)' % len(hits))
    for a, b in hits:
        print('=== SECTION at line %d: %s' % (a + 1, lines[a][:110]))
        out = []
        i = a + 1
        while i < b:
            m = LBL.match(lines[i])
            if m and len(m.group(1)) == 2 and m.group(2) == label:
                # the object line follows the label line
                if i + 1 < b:
                    om = OBJ.match(lines[i + 1])
                    if om and len(om.group(1)) == 2:
                        k = om.group(2)
                        n, sp = desc(om.group(3))
                        if kind is None or k == kind:
                            out.append((k, n, sp))
            i += 1
        for k, n, sp in out:
            print('  %-22s %-52s %s' % (k, n, sp))
        print('  COUNT[%s%s] = %d' % (label, '/' + kind if kind else '', len(out)))

main()
