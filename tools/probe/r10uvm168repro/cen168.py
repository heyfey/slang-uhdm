#!/usr/bin/env python3
"""r10uvm168 CONST-TYPE census, read straight off `uhdm-dump`.  MEASUREMENT ONLY.

Two censuses, selected by argv[2]:

  pa   — every `param_assign` whose Rhs is a `constant`.
         key     = (view, Lhs name, param_assign span)
         payload = vpiConstType | VALUE-PREFIX | vpiSize | vpiDecompile
  all  — EVERY `constant` node in the database, keyed by its own span + the
         chain of enclosing node kinds (a depth-keyed identity census, not a
         slot-keyed one: RESUME §9 "slot-keyed censuses are BLIND below the
         slot").  Payload the same.

Descended from r10vearl104repro/pacen.py (the param_assign text census that
refuses to score unless the golden side is identical between runs).  Only the
PAYLOAD changed: earl104 read the typespec chain, this reads the const type.

The VALUE PREFIX (INT/UINT/BIN/HEX/OCT) is printed alongside vpiConstType even
though `constant::Compare` reads ONLY vpiConstType, because the two are minted
together and a payload that shows only the compared field cannot tell a
re-encoding from a re-typing.
"""
import sys, re

NODE = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+):\s*(.*)$')
LABEL = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
VALPFX = ('UINT', 'INT', 'BIN', 'HEX', 'OCT', 'REAL', 'STRING', 'SCAL')


def load(path):
    out = []
    with open(path, errors='replace') as f:
        for ln in f:
            ln = ln.rstrip('\n')
            m = NODE.match(ln)
            if m:
                out.append(('N', len(m.group(1)), m.group(2), m.group(3)))
                continue
            m = LABEL.match(ln)
            if m:
                out.append(('L', len(m.group(1)), m.group(2), m.group(3)))
                continue
            out.append(('?', len(ln) - len(ln.lstrip()), '', ln.strip()))
    return out


def children(lines, i, indent):
    j = i + 1
    want = indent + 2
    while j < len(lines):
        tag, ind, key, rest = lines[j]
        if ind <= indent:
            break
        if ind == want:
            yield j, tag, ind, key, rest
        j += 1


def node_after(lines, j, indent):
    k = j + 1
    if k < len(lines) and lines[k][0] == 'N' and lines[k][1] == indent:
        return k
    return None


def span_of(rest):
    m = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', rest)
    return ':'.join(m.groups()) if m else 'LOCLESS'


def name_of(rest):
    m = re.match(r'^\s*\(([^)]*)\)', rest)
    return m.group(1) if m else ''


def const_payload(lines, k):
    """vpiConstType | value-prefix:digits | vpiSize | vpiDecompile"""
    ind = lines[k][1]
    ct = 'NONE'
    val = 'NONE'
    sz = 'NONE'
    dec = ''
    for j, t, i2, key, r in children(lines, k, ind):
        if t == 'L' and key == 'vpiConstType':
            ct = r.strip()
        elif t == 'L' and key == 'vpiSize':
            sz = r.strip()
        elif t == 'L' and key == 'vpiDecompile':
            dec = r.strip()
        elif t == 'L' and key in VALPFX:
            val = key + ':' + r.strip()
        elif t == '?' and ':' in r and r.split(':', 1)[0] in VALPFX:
            val = r
    return 'ct=%s %s size=%s dec=%s' % (ct, val, sz, dec)


def views(lines):
    """The DESIGN-level list each row belongs to, plus the weak-tail cut.

    A slot-keyed census is BLIND below the slot (RESUME §9) and a dict keyed on
    a colliding key drops rows: `allPackages` and `topPackages` hold the SAME
    package with the SAME parameter spans, so a census that does not separate
    them silently reports one of the two.  `sections` returns, per line index,
    the design-level list label in force (`uhdmallPackages`, `uhdmtopPackages`,
    `uhdmallModules`, `uhdmtopModules`, `uhdmallClasses`, …).
    """
    weak = len(lines)
    sect = ['ROOT'] * len(lines)
    cur = 'ROOT'
    for i, (t, ind, key, rest) in enumerate(lines):
        if t == 'L' and ind == 0 and key.startswith('uhdm'):
            cur = key
        sect[i] = cur
        if t == 'L' and key == '_weaklyReferenced' and i < weak:
            weak = i
    return sect, weak


def census_pa(lines):
    sect, weak = views(lines)
    cells = {}
    for i, (t, ind, kind, rest) in enumerate(lines):
        if t != 'N' or kind != 'param_assign' or i >= weak:
            continue
        # `uhdm-dump` prints a node's PARENT inline under `|vpiParent:`; that
        # back-reference is the same object again, with no children, and must
        # not be counted as a second cell (it is where the `?` rows came from).
        if i and lines[i - 1][0] == 'L' and lines[i - 1][2] == 'vpiParent':
            continue
        view = sect[i]
        span = span_of(rest)
        lhs = '?'
        payload = 'RHS-NOT-A-CONSTANT'
        for j, tg, i2, key, r in children(lines, i, ind):
            if tg != 'L':
                continue
            if key == 'vpiLhs':
                n = node_after(lines, j, i2)
                if n is not None:
                    lhs = name_of(lines[n][3]) or lines[n][2]
            elif key == 'vpiRhs':
                n = node_after(lines, j, i2)
                if n is not None and lines[n][2] == 'constant':
                    payload = const_payload(lines, n)
                elif n is not None:
                    payload = 'RHS=' + lines[n][2]
        k = (view, lhs, span)
        if k in cells and cells[k] != payload:
            # never silently drop a colliding row
            cells[k] = cells[k] + ' !!COLLIDE!! ' + payload
        else:
            cells[k] = payload
    return cells


def census_all(lines):
    """EVERY constant, keyed by (view, enclosing-kind chain, own span).  The
    chain is what keeps two constants at the same span in different owners
    apart; a multiset counter keeps duplicates (RESUME §9: a last-writer dict
    drops rows)."""
    sect, weak = views(lines)
    stack = []          # (indent, kind)
    cells = {}
    for i, (t, ind, kind, rest) in enumerate(lines):
        if t != 'N' or i >= weak:
            continue
        while stack and stack[-1][0] >= ind:
            stack.pop()
        if kind == 'constant':
            view = sect[i]
            chain = '/'.join(k for _, k in stack[-4:])
            key = (view, chain, span_of(rest), const_payload(lines, i))
            cells[key] = cells.get(key, 0) + 1
        stack.append((ind, kind))
    return cells


if __name__ == '__main__':
    lines = load(sys.argv[1])
    mode = sys.argv[2] if len(sys.argv) > 2 else 'pa'
    if mode == 'pa':
        c = census_pa(lines)
        for k in sorted(c):
            print('\t'.join(k) + '\t' + c[k])
    else:
        c = census_all(lines)
        for k in sorted(c):
            print('\t'.join(k) + '\t' + str(c[k]))
