#!/usr/bin/env python3
"""carhs.py — THE CONTINUOUS-ASSIGNMENT RHS CENSUS.

  usage: carhs.py <gold.dump> [<a.dump> [<b.dump>]]

Keyed `(section, enclosing module fullname, cont_assign span, Lhs name)` with
the payload being everything `cont_assign::Compare` can reach on the Rhs: its
object KIND and, for a constant, the fields `constant::Compare` /
`expr::Compare` read UNCLIPPED (VpiValue, VpiDecompile, VpiSize, VpiConstType)
plus the typespec its `Typespec()` points at.

FOUR TRAPS THIS INSTRUMENT IS BUILT AROUND:

 * BACKREFERENCES.  `uhdm-dump` prints an object expanded ONCE and as a bare
   one-line reference every time afterwards.  A cont_assign the ELABORATED view
   SHARES with the definition listing therefore prints with NO children under
   `uhdmtopModules`.  That is not "an empty Rhs" — it is the share itself, and
   it is recorded as the distinct payload `SHARED-WITH-DEF`.
 * `|vpiParent:` SUBTREES.  Every object prints its parent, so a cont_assign
   prints the enclosing `module_inst` INSIDE itself.  A scanner that tracks the
   enclosing module by "the last module_inst line seen" re-keys every cont
   assign under its own back-pointer.  Parent subtrees are skipped outright.
 * AN ABSENT KEY AND AN EMPTY PAYLOAD ARE NOT THE SAME.  A missing key prints
   `<no-key>`, an unreadable Rhs `<none>`.
 * COMMA-LIST ASSIGNS SHARE A SPAN.  `assign a = X, b = X;` gives both cont
   assigns the whole statement's span, so the Lhs NAME is part of the key and a
   residual collision is kept under a `dup` suffix rather than last-writer-
   dropped (the multiset trap).
"""
import re
import sys

SECT = re.compile(r'^\|uhdm(\w+):')
OBJ = re.compile(r'^\\_(\w+):')


def indent(line):
    n = 0
    for ch in line:
        if ch == ' ':
            n += 1
        else:
            break
    return n


class Node:
    __slots__ = ('kind', 'header', 'marker', 'children', 'sc')

    def __init__(self, kind, header, marker):
        self.kind = kind
        self.header = header
        self.marker = marker
        self.children = []
        self.sc = {}


def build(path):
    """-> {section: [root Node,...]}"""
    lines = [l for l in open(path, errors='replace').read().split('\n') if l.strip()]
    sections = {}
    cur = None
    stack = []          # (indent, Node)
    pending = {}        # indent -> last marker seen at that indent
    for ln in lines:
        m = SECT.match(ln)
        if m:
            cur = m.group(1)
            sections.setdefault(cur, [])
            stack = []
            pending = {}
            continue
        if cur is None:
            continue
        ind = indent(ln)
        body = ln.lstrip()
        if body.startswith('|'):
            # A `|` line at indent X belongs to the object at indent X-2; the
            # dump prints an object's BACK-POINTER subtree (`|vpiParent:` and
            # the parent object under it) BEFORE the object's own scalars, so
            # the stack must be unwound to indent X-2 first or every scalar
            # after a parent block lands on the back-pointer.
            while stack and stack[-1][0] >= ind:
                stack.pop()
            pending[ind] = body.split(':', 1)[0][1:]
            # THE SAME LINE IS BOTH a child marker and a scalar field: the dump
            # writes `|vpiSize:32` (a scalar of the object two columns out) and
            # `|vpiRhs:` (the marker of the object on the NEXT line) with the
            # same indentation.  Record it as a scalar of the enclosing object
            # unconditionally; a marker's value half is empty and harmless.
            if stack and stack[-1][0] == ind - 2 and ':' in body:
                k, v = body[1:].split(':', 1)
                stack[-1][1].sc.setdefault(k, v)
            continue
        mo = OBJ.match(body)
        if not mo:
            continue
        node = Node(mo.group(1), body, pending.get(ind, ''))
        while stack and stack[-1][0] >= ind:
            stack.pop()
        if stack:
            stack[-1][1].children.append(node)
        else:
            sections[cur].append(node)
        stack.append((ind, node))
    return sections


def field(node, name):
    """A |vpiX: scalar of THIS object is stored as the marker of nothing; the
    dump prints scalars as `|name:value` lines, which build() consumed into
    `pending`.  So scalars are re-read from the header block instead."""
    return None


def scan_scalars(path):
    """Second pass: map each object header line to its scalar fields."""
    lines = [l for l in open(path, errors='replace').read().split('\n') if l.strip()]
    out = {}
    curkey = None
    for i, ln in enumerate(lines):
        ind = indent(ln)
        body = ln.lstrip()
        if OBJ.match(body):
            curkey = (i, ind)
            out[curkey] = {}
            continue
        if body.startswith('|') and curkey and ind == curkey[1] + 2:
            if ':' in body:
                k, v = body[1:].split(':', 1)
                if k not in out[curkey]:
                    out[curkey][k] = v
    return out


def walk_named(node, want, skip_parent=True):
    """yield (child, marker) over the subtree, never entering a vpiParent."""
    for c in node.children:
        if skip_parent and c.marker == 'vpiParent':
            continue
        if c.marker == want:
            yield c
        for r in walk_named(c, want, skip_parent):
            yield r


def child_by_marker(node, marker):
    for c in node.children:
        if c.marker == marker:
            return c
    return None


def span_of(header):
    sm = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', header)
    return '%s:%s-%s:%s' % sm.groups() if sm else '-'


def name_of(header):
    m = re.match(r'\\_module_inst: (\S+)', header)
    if m:
        return m.group(1)
    m = re.match(r'\\_\w+: ?\(([^)]*)\)', header)
    return m.group(1) if m else ''


def scalars(header):
    """the |k:v lines that followed this header (filled by attach())"""
    return getattr(header, 'sc', {})


def attach(path, sections):
    """attach each object's own scalar fields, honouring indentation."""
    lines = [l for l in open(path, errors='replace').read().split('\n') if l.strip()]
    # re-run the same walk to pair Node objects with their scalar blocks
    order = []

    def collect(ns):
        for n in ns:
            order.append(n)
            collect(n.children)
    for s in sections.values():
        collect(s)
    it = iter(order)
    cur = None
    curind = None
    for ln in lines:
        ind = indent(ln)
        body = ln.lstrip()
        if SECT.match(ln):
            continue
        if OBJ.match(body):
            cur = next(it, None)
            curind = ind
            if cur is not None:
                cur.sc = {}
            continue
        if body.startswith('|') and cur is not None and ind == curind + 2:
            if ':' in body:
                k, v = body[1:].split(':', 1)
                cur.sc.setdefault(k, v)


def payload(rhs):
    if rhs is None:
        return '<none>'
    sc = getattr(rhs, 'sc', {})
    # A BARE object line with neither scalars nor children is the dump's
    # BACKREFERENCE form: the object was printed expanded somewhere earlier and
    # is SHARED here.  Reading it as "a constant with no fields" would score a
    # shared object and an empty one identically.
    if not sc and not rhs.children:
        return 'BACKREF(%s)' % rhs.kind
    if rhs.kind != 'constant':
        return 'kind=%s name=%s' % (rhs.kind, name_of(rhs.header))
    val = '-'
    for k in ('BIN', 'HEX', 'OCT', 'DEC', 'INT', 'UINT', 'REAL', 'STRING'):
        if k in sc:
            val = k + ':' + sc[k]
            break
    ts = child_by_marker(rhs, 'vpiTypespec')
    tsd = '-'
    if ts is not None:
        act = child_by_marker(ts, 'vpiActual')
        tsd = '%s->%s' % (ts.kind, (act.kind + '@' + span_of(act.header))
                          if act is not None else '<null>')
    return ('kind=constant value=%s dec=%s size=%s ct=%s ts=%s'
            % (val, sc.get('vpiDecompile', '-'), sc.get('vpiSize', '-'),
               sc.get('vpiConstType', '-'), tsd))


def parse(path):
    """key = (section, module fullname, ORDINAL within that module's
    vpiContAssign list, span); the Lhs name rides in the payload.

    THE ORDINAL, NOT THE Lhs NAME, IS THE KEY.  A cont_assign the elaborated
    view SHARES with the definition listing prints as a bare backreference with
    no Lhs at all, so an Lhs-keyed census cannot JOIN a shared cell against an
    expanded one — every share reads as a missing key on one side and a
    phantom on the other.  Document order inside one module is the only key
    both forms carry.
    """
    sections = build(path)
    out = {}

    def walk(node, sect, mod, counter):
        if node.marker == 'vpiParent':
            return
        if node.kind == 'module_inst':
            mod = name_of(node.header) or node.header
            counter = counter.setdefault(mod, [0]) if False else counter
        if node.kind == 'cont_assign':
            idx = counter.get(mod, 0)
            counter[mod] = idx + 1
            lhs = child_by_marker(node, 'vpiLhs')
            rhs = child_by_marker(node, 'vpiRhs')
            lname = '?'
            if lhs is not None:
                lname = lhs.sc.get('vpiName') or name_of(lhs.header) or \
                    ('<' + lhs.kind + '>')
            key = (sect, mod, '#%02d' % idx, span_of(node.header))
            out[key] = ('lhs=%s %s' % (lname, payload(rhs))) if node.children \
                else 'SHARED-WITH-DEF'
            return
        for c in node.children:
            walk(c, sect, mod, counter)

    for sect, roots in sections.items():
        counter = {}
        for r in roots:
            walk(r, sect, '?', counter)
    return out


def fmt(k):
    return ' | '.join(str(x) for x in k)


def main():
    g = parse(sys.argv[1])
    others = [parse(p) for p in sys.argv[2:]]
    keys = set(g)
    for o in others:
        keys |= set(o)
    if not others:
        for k in sorted(keys, key=fmt):
            print('%-78s  %s' % (fmt(k), g.get(k, '<no-key>')))
        print('KEYS %d' % len(keys))
        return
    if len(others) == 1:
        a = others[0]
        same = diff = 0
        for k in sorted(keys, key=fmt):
            gv, av = g.get(k, '<no-key>'), a.get(k, '<no-key>')
            if gv == av:
                same += 1
                continue
            diff += 1
            print('DIFF %s\n   GOLD %s\n   OURS %s' % (fmt(k), gv, av))
        print('KEYS %d SAME %d DIFF %d' % (len(keys), same, diff))
        return
    a, b = others
    sc = dict(TOGOLDEN=0, AWAYGOLDEN=0, MOVEDWRONG=0, SAMEWRONG=0, SAMERIGHT=0)
    for k in sorted(keys, key=fmt):
        gv, av, bv = g.get(k, '<no-key>'), a.get(k, '<no-key>'), b.get(k, '<no-key>')
        if av == bv:
            sc['SAMERIGHT' if av == gv else 'SAMEWRONG'] += 1
            continue
        if bv == gv:
            tag = 'TOGOLDEN'
        elif av == gv:
            tag = 'AWAYGOLDEN'
        else:
            tag = 'MOVEDWRONG'
        sc[tag] += 1
        print('%s %s\n   GOLD %s\n   A    %s\n   B    %s' % (tag, fmt(k), gv, av, bv))
    print('KEYS %d ' % len(keys)
          + ' '.join('%s=%d' % (k, v) for k, v in sorted(sc.items())))


main()
