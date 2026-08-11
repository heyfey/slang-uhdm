#!/usr/bin/env python3
"""Classify every DEFINITION of the `range 113:8-113:16` packed range in a
uhdm-dump as UNFOLDED (`operation 113:9-113:13`, i.e. `dw-1` kept) or FOLDED
(`constant 113:9-113:11`, i.e. reduced to 31), and print the enclosing view.

WHY THIS EXISTS, and the trap it closes.  YosysOldOr's head is the left bound of
that range.  The obvious counters are all WRONG:

  * `grep -c 'operation: , line:113:9, endln:113:13'` counts vpiParent
    BACK-REFERENCES as well as definitions (golden 6 hits for 2 objects).
  * counting indent-4 lines under `|vpiLeftRange:` also catches the left bounds
    of OTHER files' line-113 ranges that happen to start at column 9 -- on the
    full design that inflates golden to 2 unfolded / 8 folded when the real
    figure is 2 / 3.
  * r10oth2's loc113.py anchored on the range and reported 10 of its 15 matches
    as `?`.

So this anchors on a range DEFINITION -- a `\\_range: , line:113:8,
endln:113:16` header that is followed by a `|vpiLeftRange:` tag at a deeper
indent -- and reads that tag's child.  On the full design that yields exactly 5
objects per side, which is the figure the bisector compares.

POSITIVE CONTROL: `--expect N` exits 3 unless at least N definitions were found,
so a driver can never print a reassuring 0/0 because the probe was invisible.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours -- one dump at a time.
"""
import re
import sys

RANGE = '\\_range: , line:113:8, endln:113:16'


def ind(s):
    return len(s) - len(s.lstrip(' '))


def scan(path):
    lines = open(path).read().split('\n')
    view = '?'
    views = []
    for ln in lines:
        m = re.match(r'\|(uhdm\w+):', ln)
        views.append(m.group(1) if m else None)
    cur = '?'
    viewat = []
    for v in views:
        if v:
            cur = v
        viewat.append(cur)
    rows = []
    for i, ln in enumerate(lines):
        if ln.strip() != RANGE:
            continue
        base = ind(ln)
        form = None
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            if l2.strip() == '':
                j += 1
                continue
            if ind(l2) <= base:
                break
            if l2.strip() == '|vpiLeftRange:':
                node = lines[j + 1]
                if 'operation: , line:113:9, endln:113:13' in node:
                    form = 'UNFOLDED-op'
                elif 'constant: , line:113:9, endln:113:11' in node:
                    form = 'FOLDED-const'
                else:
                    form = 'OTHER:' + node.strip()[:40]
                break
            j += 1
        if form is None:
            continue                    # a vpiParent back-reference, not a definition
        rows.append((i + 1, viewat[i], form))
    return rows


def main():
    args = list(sys.argv[1:])
    expect = 0
    if '--expect' in args:
        k = args.index('--expect')
        expect = int(args[k + 1])
        del args[k:k + 2]
    total = 0
    for p in args:
        rows = scan(p)
        total += len(rows)
        nu = sum(1 for r in rows if r[2] == 'UNFOLDED-op')
        nf = sum(1 for r in rows if r[2] == 'FOLDED-const')
        print('===== %s' % p)
        print('  %d range-113:8 DEFINITIONS: %d UNFOLDED / %d FOLDED / %d other'
              % (len(rows), nu, nf, len(rows) - nu - nf))
        for lineno, view, form in rows:
            print('    dumpline %-9d %-16s %s' % (lineno, view, form))
    if total < expect:
        sys.stderr.write('loc113b: PROBE NOT FOUND (%d < expected %d)\n'
                         % (total, expect))
        sys.exit(3)


main()
