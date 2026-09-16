#!/usr/bin/env python3
# r11u54 SHAPE LISTER — for a uhdm-dump, print each param_assign's Rhs SHAPE,
# per top-level listing section (uhdmallPackages / uhdmtopPackages /
# uhdmallModules / uhdmtopModules).  Measurement only; the judge is uhdm-cmp.
#
# uhdm-dump layout: a field label `|vpiRhs:` at indent I is followed by its
# value head `\_kind:` at the SAME indent I, then the value's own fields at
# indent I+2.
#
# usage: shape54.py <dump> [section-substring]
import sys, re

SECT = re.compile(r'^\|uhdm(all|top)(Packages|Modules|Interfaces|Programs|Classes)\b')
CHILD_FIELDS = ('vpiOperand', 'vpiCondition', 'vpiArgument', 'vpiActual',
                'vpiExpr', 'vpiPattern', 'vpiTypespec')
ATTR_FIELDS = ('vpiSize', 'vpiDecompile', 'vpiConstType', 'vpiOpType',
               'vpiName', 'UINT', 'INT', 'BIN', 'DEC', 'HEX', 'REAL',
               'vpiLocalParam')


def ind(l):
    return len(l) - len(l.lstrip(' '))


def subtree(lines, i):
    """lines[i] is a `\\_kind:` head.  Return (block, next_index)."""
    base = ind(lines[i])
    j = i + 1
    while j < len(lines) and lines[j].strip() and ind(lines[j]) > base:
        j += 1
    return lines[i:j], j


def fields(block):
    """Yield (fieldname, valueblock-or-None) for the head's direct fields."""
    base = ind(block[0])
    i = 1
    while i < len(block):
        l = block[i]
        if ind(l) != base + 2:
            i += 1
            continue
        st = l.strip()
        if not st.startswith('|'):
            i += 1
            continue
        name = st[1:].split(':')[0]
        rest = st[1 + len(name) + 1:]
        if rest:                       # scalar field, value inline
            yield name, rest, None
            i += 1
            continue
        # composite: the head follows at the SAME indent
        if i + 1 < len(block) and block[i + 1].lstrip().startswith('\\_'):
            blk, nxt = subtree(block, i + 1)
            yield name, None, blk
            i = nxt
            continue
        i += 1


def head_of(block):
    m = re.match(r'\\_(\w+): ?(\(([^)]*)\))?(.*)', block[0].strip())
    if not m:
        return '?', '', ''
    loc = ''
    lm = re.search(r'line:(\d+:\d+)', m.group(4) or '')
    if lm:
        loc = '@' + lm.group(1)
    return m.group(1), (m.group(3) or ''), loc


def tree(block, depth=0):
    kind, nm, loc = head_of(block)
    if depth > 6:
        return kind + '...'
    attrs, kids = [], []
    for name, sval, blk in fields(block):
        if name == 'vpiParent':
            continue
        if sval is not None:
            if name in ATTR_FIELDS:
                attrs.append(f'{name}:{sval}')
            continue
        if name == 'vpiTypespec':
            tk = '?'
            for l in blk[1:]:
                m2 = re.match(r'\\_(\w+):', l.strip())
                if m2:
                    tk = m2.group(1)
                    break
            # blk[0] is the ref_typespec; its vpiActual head is the real ts
            for name2, s2, b2 in fields(blk):
                if name2 == 'vpiActual' and b2:
                    k2, n2, l2 = head_of(b2)
                    tk = k2 + (f'({n2})' if n2 else '') + l2
            attrs.append('ts=' + tk)
            continue
        if name == 'vpiActual':
            k2, n2, l2 = head_of(blk)
            kids.append('actual=' + k2 + (f'({n2})' if n2 else '') + l2)
            continue
        if name in CHILD_FIELDS:
            kids.append(tree(blk, depth + 1))
            continue
    s = kind + (f'({nm})' if nm else '') + loc
    if attrs:
        s += '{' + ','.join(attrs) + '}'
    if kids:
        s += '[' + ', '.join(kids) + ']'
    return s


def main():
    path = sys.argv[1]
    want = sys.argv[2] if len(sys.argv) > 2 else None
    lines = open(path, errors='replace').read().split('\n')
    sect = '?'
    i = 0
    while i < len(lines):
        l = lines[i]
        if SECT.match(l):
            sect = l.strip().lstrip('|').rstrip(':')
            i += 1
            continue
        if l.lstrip().startswith('\\_param_assign:'):
            blk, nxt = subtree(lines, i)
            name, rhs = '?', '<none>'
            for fn, sv, b in fields(blk):
                if fn == 'vpiLhs' and b:
                    k2, n2, l2 = head_of(b)
                    name = n2 or ('<' + k2 + '>')
                if fn == 'vpiRhs' and b:
                    rhs = tree(b)
            if want is None or want in sect:
                print(f'{sect:18s} {name:26s} {rhs}')
            i = nxt
            continue
        i += 1


main()
