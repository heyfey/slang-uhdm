#!/usr/bin/env python3
"""Print, per `assignment` object, its vpiOpType and its Rhs FORM.

Reads a uhdm-dump text (banner line already stripped) and walks the indented
tree looking for `\\_assignment:` blocks.  For each it records the source span,
the vpiOpType (which is where Surelog encodes the compound operator of
`x += 1`), the Lhs name, and the Rhs child's kind -- plus, for a constant Rhs,
its vpiDecompile / value / vpiSize / vpiConstType.  Tagged with the enclosing
view (uhdmallModules = DEF, uhdmtopModules = ELAB).

This is the instrument that reads the r10oth3 TARGET 1 arm table.  It is
POSITIVE-CONTROLLED: `--expect N` makes it exit non-zero unless it found at
least N assignment objects, so a driver can never print "no difference" because
the instrument saw nothing.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours -- this script is one-sided
and takes one dump at a time; the driver diffs its two outputs.
"""
import re
import sys


def indent(line):
    return len(line) - len(line.lstrip(' '))


def const_detail(lines, j, node):
    """Collect the interesting scalar fields of the constant at lines[j]."""
    k = j + 1
    vals = []
    while k < len(lines) and (lines[k].strip() == '' or indent(lines[k]) > indent(node)):
        t = lines[k].strip()
        if re.match(r'\|(UINT|INT|BIN|HEX|REAL|STRING|OCT|SCALAR):', t) \
           or t.startswith('|vpiConstType:') or t.startswith('|vpiSize:') \
           or t.startswith('|vpiDecompile:'):
            vals.append(t.lstrip('|'))
        k += 1
    return ' '.join(vals)


def parse(path):
    lines = open(path).read().split('\n')
    view = '?'
    out = []
    for i, ln in enumerate(lines):
        m = re.match(r'\|(uhdm\w+):', ln)
        if m:
            view = m.group(1)
            continue
        m = re.match(r'^(\s*)\\_assignment: , (line:\S+?), (endln:\S+?)$', ln)
        if not m:
            continue
        base = indent(m.group(1) + '\\')
        loc = m.group(2) + ' ' + m.group(3)
        optype, rhs, lhs = None, None, None
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            if l2.strip() == '':
                j += 1
                continue
            if indent(l2) < base:
                break
            if indent(l2) == base and not l2.lstrip().startswith('|'):
                break
            tag = l2.strip()
            if indent(l2) == base + 2:
                if tag.startswith('|vpiOpType:'):
                    optype = tag.split(':')[1]
                elif tag == '|vpiRhs:':
                    node = lines[j + 1]
                    kind = node.strip().split(':')[0].lstrip('\\_')
                    extra = ''
                    if kind == 'constant':
                        extra = ' ' + const_detail(lines, j + 1, node)
                    elif kind == 'operation':
                        k = j + 2
                        while k < len(lines) and indent(lines[k]) > indent(node):
                            if lines[k].strip().startswith('|vpiOpType:'):
                                extra = ' ' + lines[k].strip().lstrip('|')
                                break
                            k += 1
                    rhs = kind + extra
                elif tag == '|vpiLhs:':
                    node = lines[j + 1]
                    mm = re.search(r'\((?:[\w@]*\.)?(\w+)\)', node)
                    lhs = mm.group(1) if mm else node.strip()[:40]
            j += 1
        out.append((view, loc, optype, lhs, rhs))
    return out


def main():
    args = [a for a in sys.argv[1:]]
    expect = 0
    if '--expect' in args:
        k = args.index('--expect')
        expect = int(args[k + 1])
        del args[k:k + 2]
    total = 0
    for p in args:
        rows = parse(p)
        total += len(rows)
        print('===== ' + p + '  (%d assignment objects)' % len(rows))
        for view, loc, optype, lhs, rhs in rows:
            print(f'  {view:16s} {loc:34s} op={str(optype):4s} {str(lhs):14s} {str(rhs)}')
    if total < expect:
        # POSITIVE CONTROL: a census that reports zero is indistinguishable from
        # an instrument that cannot see its probe, so refuse to look successful.
        sys.stderr.write('asgform: PROBE NOT FOUND (%d < expected %d)\n' % (total, expect))
        sys.exit(3)


main()
