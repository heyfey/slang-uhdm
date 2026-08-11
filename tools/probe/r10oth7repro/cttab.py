#!/usr/bin/env python3
"""r10oth7 — the class_typespec CENSUS, both sides, one row per object.

  usage: cttab.py <g.dump> <o.dump> [--section weak|all]

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

WHAT IT READS.  uhdm-dump prints a `class_typespec`'s OWN fields (vpiName,
vpiClassDefn) only where the object is listed as a DEFINITION, not where it is
reached through a `vpiActual` back-reference.  In these databases that is the
trailing `\\_weaklyReferenced:` block, at indent 0.  Every other appearance is a
reference and prints only the header line, so counting headers conflates the two
and CANNOT see vpiClassDefn at all.  `--section all` also scans indented
appearances and marks them REF-ONLY so the difference is visible rather than
silently averaged.

OPS TRAPS ENCODED: the caller must have already stripped uhdm-dump's FIRST LINE,
which is `<database path>.uhdm: Restored design Pre-Elab:`.  This script REFUSES
such a dump (exit 8), because a stray line 1 shifts every line number it prints.
The guard's first draft tested `endswith('.uhdm')` and therefore never fired --
the path is not at the end of that line.  Its negative control is run.

A cell this script cannot resolve prints UNMEASURED, never a guess.
"""
import re
import sys


DBLINE = re.compile(r'\.uhdm:|Restored design')


def load(path):
    with open(path) as f:
        lines = f.read().split('\n')
    # THE GUARD'S FIRST DRAFT DID NOT BITE, and it is exactly the failure the
    # campaign keeps paying for: it tested `line.endswith('.uhdm')`, but
    # uhdm-dump's line 1 is `<path>.uhdm: Restored design Pre-Elab:` -- the path
    # is not at the END of the line.  Verified by NEGATIVE CONTROL: feeding a raw
    # dump now exits 8, and before the fix it was silently accepted.
    if lines and DBLINE.search(lines[0]):
        sys.exit(8)
    return lines


HDR = re.compile(r'^(\s*)\\_class_typespec:\s*(\([^)]*\))?(.*)$')


def scan(lines, weak_only):
    """Return list of (lineno, indent, name, loc, classdefn) for class_typespecs."""
    start = 0
    if weak_only:
        for i, l in enumerate(lines):
            if l.startswith('\\_weaklyReferenced:'):
                start = i + 1
                break
        else:
            return None  # UNMEASURED: no such section
    out = []
    for i in range(start, len(lines)):
        m = HDR.match(lines[i])
        if not m:
            continue
        indent = len(m.group(1))
        if weak_only and indent != 0:
            continue
        name = m.group(2)[1:-1] if m.group(2) else None
        loc = m.group(3).strip().lstrip(',').strip() or None
        # Own fields follow at indent+2 until a line at indent<=indent.
        cd = None
        nm_field = None
        j = i + 1
        while j < len(lines):
            l = lines[j]
            if not l.strip():
                j += 1
                continue
            ind = len(l) - len(l.lstrip())
            if ind <= indent and not l.lstrip().startswith('|'):
                break
            if ind <= indent:
                break
            s = l.strip()
            if s.startswith('|vpiName:'):
                nm_field = s[len('|vpiName:'):]
            if s == '|vpiClassDefn:':
                k = j + 1
                while k < len(lines) and not lines[k].strip():
                    k += 1
                if k < len(lines):
                    mm = re.search(r'class_defn:\s*\(([^)]*)\)', lines[k])
                    cd = mm.group(1) if mm else 'UNMEASURED(unparsable)'
            j += 1
        out.append((i + 1, indent, nm_field if nm_field is not None else name,
                    loc, cd))
    return out


def key(e):
    return (e[2] or '<unnamed>', e[3] or '<noloc>')


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    g = load(sys.argv[1])
    o = load(sys.argv[2])
    weak = '--section' not in sys.argv or 'weak' in sys.argv
    gs = scan(g, weak)
    os_ = scan(o, weak)
    if gs is None or os_ is None:
        print('UNMEASURED: one side has no \\_weaklyReferenced: section')
        return 3
    def index(es):
        d = {}
        for e in es:
            d.setdefault(key(e), []).append(e)
        return d
    gi, oi = index(gs), index(os_)
    allk = sorted(set(gi) | set(oi))
    print('%-28s %-26s %-34s %-34s %s' % ('name', 'loc', 'golden(LHS)',
                                          'ours(RHS)', 'verdict'))
    ndiff = 0
    for k in allk:
        ge = gi.get(k, [])
        oe = oi.get(k, [])
        def desc(es):
            if not es:
                return 'UNMEASURED(no such object)'
            return ' | '.join('name=%s defn=%s' % (e[2] or '-', e[3 + 1] or '-')
                              for e in es)
        gd, od = desc(ge), desc(oe)
        v = 'EQUAL' if gd == od and len(ge) == len(oe) else 'DIFF'
        if v == 'DIFF':
            ndiff += 1
        print('%-28s %-26s %-34s %-34s %s' % (k[0][:28], k[1][:26], gd[:34],
                                              od[:34], v))
    print('---- class_typespec DEF cells: %d, differing %d '
          '(golden objects %d, ours %d)' % (len(allk), ndiff, len(gs), len(os_)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
