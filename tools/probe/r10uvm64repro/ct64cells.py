#!/usr/bin/env python3
"""r10uvm64 CELL READER — does a `ref_obj` carry `vpiActual`, on each side?

    usage: ct64cells.py <g.dump> <o.dump> [name-substring ...]

THE CELL KEY IS THE REF'S OWN `line:COL`, not its name and not its dump-line
number.  Both sides span a reference identically (verified on the corpus head:
`ref_obj (…::handle), line:346:75, endln:346:81` is byte-identical on both
sides), so the span is the only key that cannot drift when one side emits an
extra object above it.

THREE TRAPS THIS READER ENCODES, each one paid for by an earlier pass:

  * AN OBJECT IS NOT A DUMP OCCURRENCE.  uhdm-dump prints the same ref_obj many
    times — once at its fullest occurrence and again as a one-line back-
    reference under every other parent.  A back-reference prints NO own fields,
    so reading fields off the FIRST occurrence reports EVERY cell as unbound on
    BOTH sides: a perfect-looking, perfectly wrong table.  This reader keeps,
    per (span) key, the occurrence with the MOST own fields.

  * OWN FIELDS ONLY.  `|vpiActual:` at own-child indent belongs to this ref;
    the identical text two levels deeper belongs to a grandchild.  Indentation
    is the only thing that separates them, so the indent is measured, not
    assumed.

  * A CELL MEASURED ON ONE SIDE ONLY IS NOT AGREEMENT.  A span present in one
    dump and absent from the other prints -NOOBJ- and is counted in its own
    bucket (UNMEASURED), never as `same`.

  * THE KEY IS THE SPAN ALONE, NOT (name, span) — ON A SINGLE-FILE ARM.
    Measured on arm b2: golden names an OUT-OF-BODY method's refs `o1.farg`
    where we name them `farg`.  Keying on the name too SPLIT every one of those
    cells into two -NOOBJ- halves and reported 10 UNMEASURED where the real
    reading is 4 agreements and 2 disagreements plus ONE pre-existing NAMING
    residue.  A key that contains the thing under test is not a key.  The names
    are printed side by side and a mismatch is called out as NAME-DIFFERS, so
    the residue stays visible instead of being folded into the verdict.

  * ...AND THE SPAN ALONE IS NOT A KEY ON A MULTI-FILE DESIGN.  uhdm-dump does
    NOT print the FILE, so `line:116:11` in uvm_pkg.sv's ~200 included files is
    ~200 different references.  Run with NAMEKEY=1 for a whole-design reading:
    the key becomes (vpiFullName, span), which is unique in practice, and the
    b2-style naming residue then shows up as UNMEASURED instead of corrupting a
    verdict.  A whole-design table read with the arm's key is NOT a measurement
    — this was caught mid-pass by noticing 285 NAME-DIFFERS on SimpleUVM, and
    both readings are reported in the README rather than the convenient one.
"""
import os
import re
import sys

NAMEKEY = os.environ.get('NAMEKEY', '0') == '1'

REF = re.compile(r'^(\s*)\\_(\w+): \(([^)]*)\)(?:, line:(\d+):(\d+), endln:(\d+):(\d+))?')
HDR = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')


def scan(path, kinds):
    """-> {(kind, name, line, col): set(own field names)} keeping the FULLEST."""
    best = {}
    lines = open(path, 'rt', errors='replace').read().splitlines()
    for i, ln in enumerate(lines):
        m = REF.match(ln)
        if not m:
            continue
        indent, kind, name, l, c = m.group(1), m.group(2), m.group(3), m.group(4), m.group(5)
        if kinds and kind not in kinds:
            continue
        if l is None:
            continue
        own = len(indent) + 2
        fields = set()
        for j in range(i + 1, len(lines)):
            nx = lines[j]
            if not nx.strip():
                break
            ind = len(nx) - len(nx.lstrip())
            if ind < own:
                break
            if ind != own:
                continue
            f = FLD.match(nx)
            if f:
                fields.add(f.group(2))
            elif nx.lstrip().startswith('\\_'):
                continue
            else:
                break
        key = (int(l), int(c), name) if NAMEKEY else (int(l), int(c))
        if key not in best or len(fields) > len(best[key][1]):
            best[key] = (name, fields)
    return best


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    g = scan(sys.argv[1], {'ref_obj'})
    o = scan(sys.argv[2], {'ref_obj'})
    pats = sys.argv[3:]
    keys = sorted(set(g) | set(o))
    same = differ = unmeasured = namediff = 0
    print('%-24s %-9s %-9s %-9s %-11s %s' %
          ('G REF NAME', 'O REF NAME', 'SPAN', 'GOLDEN', 'OURS', 'VERDICT'))
    for k in keys:
        l, c = k[0], k[1]
        gn = g[k][0].split('::')[-1] if k in g else ''
        on = o[k][0].split('::')[-1] if k in o else ''
        if pats and not any(p in gn or p in on for p in pats):
            continue
        note = ''
        if gn and on and gn != on:
            note = ' NAME-DIFFERS'
            namediff += 1
        if k in g and k in o:
            gb = 'vpiActual' in g[k][1]
            ob = 'vpiActual' in o[k][1]
            if gb == ob:
                same += 1
                v = 'same'
            else:
                differ += 1
                v = 'DIFFER'
            print('%-24s %-9s %-9s %-9s %-11s %s' %
                  (gn, on, '%d:%d' % (l, c), 'BIND' if gb else 'bare',
                   'BIND' if ob else 'bare', v + note))
        else:
            unmeasured += 1
            print('%-24s %-9s %-9s %-9s %-11s %s' %
                  (gn or '-', on or '-', '%d:%d' % (l, c),
                   ('BIND' if 'vpiActual' in g[k][1] else 'bare') if k in g else '-NOOBJ-',
                   ('BIND' if 'vpiActual' in o[k][1] else 'bare') if k in o else '-NOOBJ-',
                   'UNMEASURED' + note))
    print('---- cells=%d same=%d DIFFER=%d UNMEASURED=%d NAME-DIFFERS=%d' %
          (same + differ + unmeasured, same, differ, unmeasured, namediff))
    if same + differ + unmeasured == 0:
        print('REFUSING TO REPORT: matched no ref_obj at all')
        return 5
    return 0


if __name__ == '__main__':
    sys.exit(main())
