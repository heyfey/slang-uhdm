#!/usr/bin/env python3
"""Print, for every packed-RANGE DEFINITION in a uhdm-dump, the range's span and
the FORM of its left and right bounds (UNFOLDED `operation opType=N` vs FOLDED
`constant <value>`), tagged with the enclosing view.

This is loc113b.py generalised off YosysOldOr's one hard-coded span, so the
synthetic arms can be read the same way the corpus witness is.  A range
DEFINITION is a `\\_range:` header that owns a `|vpiLeftRange:` tag at a deeper
indent; a `\\_range:` header printed as a vpiParent BACK-REFERENCE owns nothing
and is skipped -- counting back-references is what made every earlier count of
this object wrong.

POSITIVE CONTROL: `--expect N` exits 3 unless at least N definitions were found.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours -- one dump at a time.
"""
import re
import sys


def ind(s):
    return len(s) - len(s.lstrip(' '))


def form(lines, j, node):
    st = node.strip()
    kind = st.split(':')[0].lstrip('\\_')
    if kind == 'operation':
        for k in range(j + 1, min(j + 40, len(lines))):
            if ind(lines[k]) <= ind(node):
                break
            if lines[k].strip().startswith('|vpiOpType:'):
                return 'op(%s)' % lines[k].strip().split(':')[1]
        return 'op(?)'
    if kind == 'constant':
        val = '?'
        for k in range(j + 1, min(j + 40, len(lines))):
            if ind(lines[k]) <= ind(node):
                break
            m = re.match(r'\|(UINT|INT|BIN|HEX|OCT|SCALAR):(\S*)',
                         lines[k].strip())
            if m:
                val = m.group(1) + ':' + m.group(2)
                break
        return 'const(%s)' % val
    return kind


def scan(path):
    lines = open(path).read().split('\n')
    cur = '?'
    viewat = []
    for ln in lines:
        m = re.match(r'\|(uhdm\w+):', ln)
        if m:
            cur = m.group(1)
        viewat.append(cur)
    rows = []
    for i, ln in enumerate(lines):
        m = re.match(r'^\s*\\_range: , (line:\S+?), (endln:\S+?)$', ln)
        if not m:
            continue
        base = ind(ln)
        span = m.group(1) + '-' + m.group(2)
        lf, rf = None, None
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            if l2.strip() == '':
                j += 1
                continue
            if ind(l2) <= base:
                break
            if l2.strip() == '|vpiLeftRange:':
                lf = form(lines, j + 1, lines[j + 1])
            elif l2.strip() == '|vpiRightRange:':
                rf = form(lines, j + 1, lines[j + 1])
            j += 1
        if lf is None and rf is None:
            continue                    # back-reference, not a definition
        rows.append((viewat[i], span, lf, rf))
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
        counts = {}
        for r in rows:
            counts[r] = counts.get(r, 0) + 1
        print('===== %s  (%d range definitions)' % (p, len(rows)))
        for (view, span, lf, rf), n in sorted(counts.items(), key=lambda x: x[0][1]):
            print('  %2dx %-16s %-38s L=%-14s R=%s' % (n, view, span, lf, rf))
    if total < expect:
        sys.stderr.write('rangeform: PROBE NOT FOUND (%d < expected %d)\n'
                         % (total, expect))
        sys.exit(3)


main()
