#!/usr/bin/env python3
"""r10earl82 — a SPAN-KEYED CONSTANT CENSUS over a uhdm-dump text.

MEASUREMENT ONLY.  Reads a dump; dispatches nothing.

For every `constant` object it records
    (span, vpiParent's KIND, vpiDecompile, vpiSize, vpiValue, vpiConstType)
and emits a MULTISET (a count per distinct row), never a last-writer dict
(RESUME §9: a last-writer dict drops rows when keys collide, and the same
written bound legitimately appears once per view and once per instance).

The key carries the SPAN because a grid arm must name WHICH written bound
moved; the JUDGE never reads a span, so a score against golden is taken on the
judge-visible payload (decompile / size / value / consttype) alone.

Parsing rule: a field of the object is a line at EXACTLY indent+2 beginning
with `|`; the object named by the preceding field is the `\\_` line at the same
indent+2.  Anything deeper belongs to that referenced object, and the block
ends at the first line whose indent is <= the object's own.

usage: cencon82.py <dump> [--val PREFIX] [--parent KIND]
"""
import re, sys, collections

CONST_RE = re.compile(
    r'^(\s*)\\_constant: (?:\(([^)]*)\) )?, (?:id:\d+, )?line:(\d+):(\d+), endln:(\d+):(\d+)')
VAL_RE = re.compile(r'^\|(UINT|INT|BIN|HEX|OCT|REAL|STRING|SCAL):')


skipped = [0]


def census(fn):
    rows = []
    lines = open(fn, errors='replace').read().split('\n')
    n = len(lines)
    for i, l in enumerate(lines):
        m = CONST_RE.match(l)
        if not m:
            continue
        ind = len(m.group(1))
        span = f"{m.group(3)}:{m.group(4)}-{m.group(5)}:{m.group(6)}"
        dec = size = val = ct = None
        par = None
        lastfield = None
        j = i + 1
        while j < n:
            lj = lines[j]
            if not lj.strip():
                j += 1
                continue
            ind2 = len(lj) - len(lj.lstrip())
            if ind2 <= ind:
                break
            if ind2 != ind + 2:
                j += 1
                continue
            s = lj.strip()
            if s.startswith('|'):
                lastfield = s
                if s.startswith('|vpiDecompile:'):
                    dec = s.split(':', 1)[1]
                elif s.startswith('|vpiSize:'):
                    size = s.split(':', 1)[1]
                elif s.startswith('|vpiConstType:'):
                    ct = s.split(':', 1)[1]
                elif VAL_RE.match(s):
                    val = s[1:]
            elif s.startswith('\\_') and lastfield == '|vpiParent:':
                pm = re.match(r'\\_(\w+):', s)
                if pm:
                    par = pm.group(1)
            j += 1
        # A uhdm-dump RE-PRINT of an already-visited object carries no fields
        # at all; counting it would manufacture phantom cells (RESUME §9's
        # NODEDUP trap).  Skip it and say so in the tally.
        if dec is None and size is None and val is None and ct is None:
            skipped[0] += 1
            continue
        rows.append((span, par or '?', dec or '-', size or '-', val or '-', ct or '-'))
    return rows


if __name__ == '__main__':
    fn = sys.argv[1]
    pfx = None
    if '--val' in sys.argv:
        pfx = sys.argv[sys.argv.index('--val') + 1]
    pk = None
    if '--parent' in sys.argv:
        pk = sys.argv[sys.argv.index('--parent') + 1]
    nopar = '--nopar' in sys.argv
    c = collections.Counter()
    for r in census(fn):
        if pfx and (r[4] or '').split(':')[0] != pfx:
            continue
        if pk and r[1] != pk:
            continue
        if nopar:
            r = (r[0],) + r[2:]
        c[r] += 1
    for k in sorted(c):
        print(f"{c[k]}\t" + "\t".join(str(x) for x in k))
    print(f"# reprints-skipped={skipped[0]}  rows={sum(c.values())}  distinct={len(c)}",
          file=sys.stderr)
