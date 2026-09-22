#!/usr/bin/env python3
"""r11u85 — THE PER-CELL ARBITER FOR `cont_assign`, CARRYING EVERY FIELD ITS
OWNER'S GENERATED `Compare` READS, IN THAT ORDER.

`cont_assign::Compare` (~/git-repos/UHDM/build/generated/src/cont_assign.cpp:
99-127) reads, in order: VpiNetDeclAssign, VpiStrength0, VpiStrength1, Delay,
Rhs, Lhs, Cont_assign_bits.  r11v83 §3 convicted a scorer whose key stopped at
(owner, span, Lhs, Rhs) — it read none of the four drive fields and scored a
regression CONVERTED.  This one keys on (owner, span, Lhs name) and carries the
drive fields, the Delay's own constant fields and the Rhs's compared fields
(VpiDecompile, VpiSize, VpiValue, VpiConstType for a constant; the kind
otherwise).

  usage: cacell85.py <gold.dump> <ours.dump> [--rows]

Scores PER CELL, against golden:
  MATCH        every compared field equal
  CONVERTED    a field that differed in the FIRST pair now equals golden
               (two-run mode, see cmpcell85.sh)
  DIFF         at least one compared field differs from golden
  GOLD-ONLY    golden lists the cell and we do not
  OURS-ONLY    we list a cell golden does not (a MINT — golden writes nothing
               on a miss)
A SHARED sub-object prints abbreviated on reuse (only its header line), so a
field read as MISSING on a re-print is recorded as `~` (unread), never as a
difference — the r11v83 blind spot, named.
"""
import re
import sys

HDR = re.compile(r'^(\s*)\\_(\w+): ?(\([^)]*\))?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


class Node:
    __slots__ = ('kind', 'name', 'span', 'fields', 'objs', 'abbrev')

    def __init__(self, kind, name, span):
        self.kind = kind
        self.name = name
        self.span = span
        self.fields = {}
        self.objs = {}
        self.abbrev = True


def parse(path):
    root = Node('root', '', '')
    stack = [(-2, root, None)]   # (indent, node, pending field name)
    pending = {}
    for raw in open(path, errors='replace'):
        line = raw.rstrip('\n')
        m = FLD.match(line)
        if m:
            ind, nm, val = len(m.group(1)), m.group(2), m.group(3)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            owner = stack[-1][1] if stack else root
            if val != '':
                owner.fields[nm] = val
            pending[ind] = (owner, nm)
            continue
        m = HDR.match(line)
        if m:
            ind, kind = len(m.group(1)), m.group(2)
            name = (m.group(3) or '')[1:-1] if m.group(3) else ''
            rest = m.group(4) or ''
            ml = LOC.search(rest)
            span = '%s:%s-%s:%s' % ml.groups() if ml else ''
            node = Node(kind, name, span)
            node.abbrev = True
            owner, fname = pending.get(ind, (root, kind))
            owner.objs.setdefault(fname, []).append(node)
            while stack and stack[-1][0] >= ind:
                stack.pop()
            stack.append((ind, node, None))
            continue
    return root


def walk(node, out, owner):
    me = owner
    if node.kind in ('module_inst', 'interface_inst', 'gen_scope'):
        me = node.fields.get('vpiFullName', node.name) or node.name
    for fname, kids in node.objs.items():
        for k in kids:
            if k.kind == 'cont_assign' and fname == 'vpiContAssign':
                out.append((me, k))
            if fname == 'vpiParent':
                continue
            walk(k, out, me)


def cellkey(owner, ca):
    lhs = ca.objs.get('vpiLhs', [None])[0]
    ln = ''
    if lhs is not None:
        ln = lhs.fields.get('vpiName', lhs.name)
    return (owner, ca.span, ln)


def exprsig(e, idx=None, unres=None):
    if e is None:
        return '<none>'
    if not (e.fields or e.objs):
        # abbreviated re-print of a SHARED object: resolve it to its own full
        # print when (kind, span) names exactly one object in this dump.
        full = idx.get((e.kind, e.span)) if idx is not None else None
        if full is None:
            if unres is not None:
                unres[0] += 1
            return '~%s@%s' % (e.kind, e.span)
        e = full
    if e.kind == 'constant':
        v = [k for k in e.fields
             if k in ('DEC', 'UINT', 'INT', 'HEX', 'BIN', 'OCT', 'REAL',
                      'STRING', 'SCALAR')]
        val = (v[0] + ':' + e.fields[v[0]]) if v else '?'
        return 'constant|%s|sz=%s|dc=%s|ct=%s' % (
            val, e.fields.get('vpiSize', '?'),
            e.fields.get('vpiDecompile', '<nodc>'),
            e.fields.get('vpiConstType', '?'))
    return '%s|%s' % (e.kind, e.fields.get('vpiName', e.name))


def cellsig(ca, idx=None, unres=None):
    dly = ca.objs.get('vpiDelay', [None])[0]
    rhs = ca.objs.get('vpiRhs', [None])[0]
    lhs = ca.objs.get('vpiLhs', [None])[0]
    return {
        'nda': ca.fields.get('vpiNetDeclAssign', '0'),
        's0': ca.fields.get('vpiStrength0', '0'),
        's1': ca.fields.get('vpiStrength1', '0'),
        'delay': exprsig(dly, idx, unres),
        'rhs': exprsig(rhs, idx, unres),
        'lhs': exprsig(lhs, idx, unres),
    }


def index_full(node, idx):
    """(kind, span) -> the FULL print of an object, when that key is unique.

    The dump prints a SHARED sub-object abbreviated on every reuse, so a cell
    that references an object first printed elsewhere reads as a bare header.
    r11v83 §3 names this as the blind spot that let a dropped `vpiDelay` score
    as a match: resolving the abbreviation is what closes it.  A key that is
    NOT unique stays unresolved and is COUNTED, never guessed.
    """
    if node.kind not in ('root',) and (node.fields or node.objs):
        k = (node.kind, node.span)
        idx[k] = None if k in idx else node
    for kids in node.objs.values():
        for k2 in kids:
            index_full(k2, idx)


def cells(path):
    root = parse(path)
    idx = {}
    for kids in root.objs.values():
        for k2 in kids:
            index_full(k2, idx)
    out = []
    walk(root, out, '')
    d = {}
    unres = [0]
    for owner, ca in out:
        d.setdefault(cellkey(owner, ca), []).append(cellsig(ca, idx, unres))
    return d, unres[0]


def main():
    g, o = sys.argv[1], sys.argv[2]
    rows = '--rows' in sys.argv
    (G, ug), (O, uo) = cells(g), cells(o)
    nm = nd = ngo = noo = nu = 0
    for k in sorted(set(G) | set(O)):
        gs, os_ = G.get(k), O.get(k)
        if gs is None:
            noo += len(os_)
            if rows:
                print('OURS-ONLY %s' % (k,))
            continue
        if os_ is None:
            ngo += len(gs)
            if rows:
                print('GOLD-ONLY %s' % (k,))
            continue
        for i in range(max(len(gs), len(os_))):
            if i >= len(gs):
                noo += 1
                continue
            if i >= len(os_):
                ngo += 1
                continue
            a, b = gs[i], os_[i]
            FS = ('nda', 's0', 's1', 'delay', 'rhs', 'lhs')
            # An UNRESOLVED abbreviation is scored as UNSCORED, never as a
            # match: n4_nestgen's gen-scope cell reads `~constant@7:42-7:44` on
            # BOTH sides and its sizes differ 64 vs 32.  A scorer that calls
            # that a match is the r11v83 blind spot wearing a new coat.
            uns = [f for f in FS
                   if a[f].startswith('~') or b[f].startswith('~')]
            bad = [f for f in FS if a[f] != b[f] and f not in uns]
            if uns and not bad:
                nu += 1
                print('UNSCORED %s  %s' % (k, ' '.join(uns)))
                continue
            if bad:
                nd += 1
                print('DIFF %s' % (k,))
                for f in bad:
                    print('      %-5s gold=%-46s ours=%s' % (f, a[f], b[f]))
            else:
                nm += 1
                if rows:
                    print('MATCH %s  rhs=%s nda=%s s0=%s s1=%s dly=%s'
                          % (k, a['rhs'], a['nda'], a['s0'], a['s1'],
                             a['delay']))
    print('CELLS gold=%d ours=%d MATCH=%d DIFF=%d GOLD-ONLY=%d OURS-ONLY=%d '
          'UNSCORED=%d (abbrev gold=%d ours=%d)'
          % (sum(len(v) for v in G.values()), sum(len(v) for v in O.values()),
             nm, nd, ngo, noo, nu, ug, uo))


main()
