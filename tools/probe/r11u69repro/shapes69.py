#!/usr/bin/env python3
"""r11u69 SHAPE LISTER — every cont_assign in a uhdm-dump, with its OWNING
scope, its Lhs name and its Rhs SHAPE (kind + the fields the judge reads:
decompile/size/value/constType, and the location of the Rhs object).

Sections: `elab` = uhdmtopModules (the elaborated view), `def` =
uhdmallModules (the definition view, the byte-identical control).

usage: r11u69_shapes.py <dump> [elab|def]
"""
import re
import sys


def indent(line):
    return len(line) - len(line.lstrip(' '))


def parse(path, section):
    lines = open(path, errors='replace').read().split('\n')
    marker = '|uhdmtopModules:' if section == 'elab' else '|uhdmallModules:'
    start = None
    end = len(lines)
    for i, l in enumerate(lines):
        if l.strip() == marker:
            start = i
        elif start is not None and l.startswith('|uhdm') and i > start:
            end = i
            break
    if start is None:
        return []
    return lines[start + 1:end]


OBJ = re.compile(r'^(\s*)\\_(\w+): ?(\(([^)]*)\))?(.*)$')


def loc(rest):
    m = re.search(r'line:(\d+:\d+)', rest or '')
    return m.group(1) if m else '-'


FULL = {}

KEEP = ('vpiDecompile', 'vpiSize', 'vpiConstType', 'vpiName', 'vpiOpType')


def build_full(path):
    """(kind, loc) -> the fields of the FIRST FULL print of such an object.

    uhdm-dump prints an object it has already visited as a bare stub, so a
    reader that takes the stub at face value sees a field-less object where
    the database holds a full one.  This index is what resolves the stub."""
    FULL.clear()
    lines = open(path, errors='replace').read().split('\n')
    for i, l in enumerate(lines):
        m = OBJ.match(l)
        if not m:
            continue
        base = len(m.group(1))
        fields = {}
        for lk in lines[i + 1:]:
            if not lk.strip():
                continue
            if indent(lk) <= base:
                break
            t = lk.strip()
            if indent(lk) == base + 2 and t.startswith('|'):
                key, _, val = t[1:].partition(':')
                if key in KEEP or key.isupper():
                    fields[key] = val
        if fields:
            FULL.setdefault((m.group(2), loc(m.group(5))), fields)


def run(path, section):
    build_full(path)
    body = parse(path, section)
    # stack of (indent, kind, name) for scope objects
    scopes = []
    out = []
    i = 0
    while i < len(body):
        l = body[i]
        m = OBJ.match(l)
        # A `\_kind:` line printed under `|vpiParent:` is a BACK-REFERENCE, not
        # an object of the walk — counting it manufactures phantom cells.
        if m and i > 0 and body[i - 1].strip() == '|vpiParent:':
            i += 1
            continue
        if m:
            ind, kind, name = len(m.group(1)), m.group(2), m.group(4) or ''
            while scopes and scopes[-1][0] >= ind:
                scopes.pop()
            if kind in ('module_inst', 'gen_scope', 'interface_inst'):
                scopes.append((ind, kind, name))
            if kind == 'cont_assign':
                owner = scopes[-1][2] if scopes else '?'
                # subtree: every line more indented than this one
                j = i + 1
                sub = []
                while j < len(body):
                    lj = body[j]
                    if lj.strip() == '':
                        j += 1
                        continue
                    if indent(lj) <= ind and (OBJ.match(lj) or
                                              lj.lstrip().startswith('|')):
                        break
                    sub.append(lj)
                    j += 1
                rhs = lhs = None
                for k, lk in enumerate(sub):
                    t = lk.strip()
                    if t == '|vpiRhs:' and rhs is None:
                        rhs = sub[k + 1:]
                    if t == '|vpiLhs:' and lhs is None:
                        lhs = sub[k + 1:]

                def first(objlines):
                    if not objlines:
                        return ('-', '-', '-', {})
                    mm = OBJ.match(objlines[0])
                    if not mm:
                        return ('?', '?', '?', {})
                    kk, nn = mm.group(2), mm.group(4) or ''
                    base = len(mm.group(1))
                    fields = {}
                    # A uhdm-dump object printed with NO children at all is a
                    # REPEAT of an object the walk already printed — i.e. the
                    # object is SHARED.  That is the only share signal the
                    # dump gives (it prints no ids), so the lister names it.
                    if (len(objlines) < 2 or not objlines[1].strip() or
                            indent(objlines[1]) <= base):
                        # Resolve it against the FIRST full print of an object
                        # with the same kind+location: uhdm-dump elides a repeat
                        # but the OBJECT still carries its fields, and reading a
                        # repeat as "field-less" is the falling-count trap.
                        key = (kk, loc(mm.group(5)))
                        f = FULL.get(key)
                        if f is not None:
                            f = dict(f)
                            f['!'] = 'shared-repeat'
                            return (kk, nn, loc(mm.group(5)), f)
                        return (kk, nn, loc(mm.group(5)),
                                {'!': 'REPEAT/unresolved'})
                    for lk in objlines[1:]:
                        if not lk.strip():
                            continue
                        if indent(lk) <= base:
                            break
                        t = lk.strip()
                        if indent(lk) == base + 2 and t.startswith('|'):
                            key, _, val = t[1:].partition(':')
                            if key in ('vpiDecompile', 'vpiSize',
                                       'vpiConstType', 'vpiName',
                                       'vpiOpType') or key.isupper():
                                fields[key] = val
                    return (kk, nn, loc(mm.group(5)), fields)

                rk, rn, rl, rf = first(rhs)
                lk_, ln_, ll_, lf = first(lhs)
                fstr = ' '.join(f'{k}={v}' for k, v in sorted(rf.items()))
                out.append(f'{owner}\tca@{loc(m.group(5))}\t'
                           f'LHS={lk_}({ln_ or lf.get("vpiName","")})\t'
                           f'RHS={rk}({rn})@{rl}\t{fstr}')
                i = j
                continue
        i += 1
    return out


if __name__ == '__main__':
    sec = sys.argv[2] if len(sys.argv) > 2 else 'elab'
    for r in run(sys.argv[1], sec):
        print(r)
