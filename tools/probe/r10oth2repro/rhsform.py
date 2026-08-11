#!/usr/bin/env python3
"""Print, per parameter name, the param_assign Rhs FORM in each module view.

Reads a uhdm-dump text (banner line already stripped) and walks the indented
tree looking for `\\_param_assign:` blocks.  For each it records the Rhs child's
kind (+value for a constant) and the Lhs parameter's name, tagged with the
enclosing view (uhdmallModules = DEF, uhdmtopModules = ELAB, uhdmallPackages /
uhdmtopPackages likewise).

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours -- this script is view-only
and takes one dump at a time.
"""
import re
import sys


def indent(line):
    return len(line) - len(line.lstrip(' '))


def parse(path):
    lines = open(path).read().split('\n')
    view = '?'
    out = []
    i = 0
    while i < len(lines):
        ln = lines[i]
        m = re.match(r'\|(uhdm\w+):', ln)
        if m:
            view = m.group(1)
            i += 1
            continue
        m = re.match(r'^(\s*)\\_param_assign: , (line:\S+?), (endln:\S+?)$', ln)
        if not m:
            i += 1
            continue
        base = indent(m.group(1) + '\\')
        loc = m.group(2) + ' ' + m.group(3)
        # scan the block body at indent base+2 for |vpiRhs: / |vpiLhs:
        rhs, lhs = None, None
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            if l2.strip() == '':
                j += 1
                continue
            if indent(l2) <= base and not l2.lstrip().startswith('|'):
                break
            if indent(l2) < base:
                break
            tag = l2.strip()
            if tag == '|vpiRhs:' and indent(l2) == base + 2:
                node = lines[j + 1]
                kind = node.strip().split(':')[0].lstrip('\\_')
                extra = ''
                if kind == 'constant':
                    k = j + 2
                    vals = []
                    while k < len(lines) and indent(lines[k]) > indent(node):
                        t = lines[k].strip()
                        if re.match(r'\|(UINT|INT|BIN|HEX|REAL|STRING|OCT|SCALAR):', t) \
                           or t.startswith('|vpiConstType:') or t.startswith('|vpiSize:'):
                            vals.append(t.lstrip('|'))
                        k += 1
                    extra = ' ' + ' '.join(vals)
                elif kind == 'operation':
                    k = j + 2
                    while k < len(lines) and indent(lines[k]) > indent(node):
                        t = lines[k].strip()
                        if t.startswith('|vpiOpType:'):
                            extra = ' ' + t.lstrip('|')
                            break
                        k += 1
                rhs = kind + extra
            if tag == '|vpiLhs:' and indent(l2) == base + 2:
                node = lines[j + 1]
                mm = re.search(r'\((?:[\w@]*\.)?(\w+)\)', node)
                lhs = mm.group(1) if mm else node.strip()[:40]
            j += 1
        out.append((view, lhs, loc, rhs))
        i += 1
    return out


for p in sys.argv[1:]:
    print('===== ' + p)
    for view, lhs, loc, rhs in parse(p):
        print(f'  {view:18s} {str(lhs):24s} {str(rhs)}')
