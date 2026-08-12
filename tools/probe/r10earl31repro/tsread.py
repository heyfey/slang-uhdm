#!/usr/bin/env python3
"""r10earl31 — the TYPESPEC-ON-FOLDED-CONSTANT reader.

Parses a `uhdm-dump` (first line already stripped with `sed 1d`) into a tree and
answers ONE question per `constant`: does it carry a `vpiTypespec`, and what does
that typespec's `vpiActual` point at?

THE TWO PARSING TRAPS THIS FILE ENCODES (both paid for by earlier passes):

* An object introduced by a field line (`|vpiTypespec:` -> `\\_ref_typespec:`) is
  printed at the SAME indent as the enclosing object's own field lines.  The
  disambiguator is that the introduced object's OWN fields sit two columns
  deeper, so a `|field:` line at the introduced object's indent belongs to the
  ENCLOSING object.  r10earl30 §7 shows what reading this wrong costs: every
  constant carrying a typespec was read as having no `vpiConstType`, which faked
  an over-fire.
* `|vpiParent:` / `|vpiActual:` back-references print a STUB of an
  already-visited object (type + span, no children).  A stub must never be
  mistaken for the real object, so the reader records back-reference children by
  TYPE + SPAN only and never descends into them for census purposes.

Span keys are NOT usable as a join key across the two sides: the whole point of
this pass's witness is that golden spans `408:65-408:69` where we span
`408:65-408:78`.  The join key is therefore
(nearest named ancestor's vpiFullName, START line:col, vpiDecompile).
"""
import re
import sys

OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): (.*)$')
FLD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
VAL = re.compile(r'^(\s*)\|(BIN|DEC|HEX|OCT|INT|UINT|REAL|STRING|SCALAR|NOVAL):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+)(?:, endln:(\d+):(\d+))?')


class Node:
    __slots__ = ('type', 'field', 'span', 'sspan', 'name', 'fullname', 'fields',
                 'kids', 'parent', 'stub')

    def __init__(self, typ, field, raw):
        self.type = typ
        self.field = field          # the field that introduced this object
        m = LOC.search(raw)
        if m:
            self.sspan = '%s:%s' % (m.group(1), m.group(2))
            self.span = self.sspan + '-' + (
                '%s:%s' % (m.group(3), m.group(4)) if m.group(3) else '?')
        else:
            self.sspan = '?'
            self.span = '?'
        mn = re.match(r'^\(([^)]*)\)', raw.strip())
        self.name = mn.group(1) if mn else ''
        self.fullname = ''
        self.fields = {}
        self.kids = []
        self.parent = None
        self.stub = False


def parse(path, want=('constant',)):
    """Return the list of nodes whose type is in `want`, each with its ancestor
    chain wired up.  Everything else is kept only as far as the chain needs."""
    root = Node('DESIGN', '', '')
    stack = [(-2, root)]
    cur_field = {}
    out = []
    with open(path, 'rt', errors='replace') as f:
        for line in f:
            line = line.rstrip('\n')
            m = OBJ.match(line)
            if m:
                ind = len(m.group(1))
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                parent = stack[-1][1] if stack else root
                n = Node(m.group(2), cur_field.get(id(parent), ''), m.group(3))
                n.parent = parent
                # A back-reference (vpiParent / an already-visited vpiActual)
                # prints a stub; mark it so no census reads its (absent) fields.
                n.stub = n.field in ('vpiParent',)
                parent.kids.append(n)
                if n.type in want:
                    out.append(n)
                stack.append((ind, n))
                continue
            m = FLD.match(line)
            if m:
                ind = len(m.group(1))
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                owner = stack[-1][1] if stack else root
                fname, fval = m.group(2), m.group(3)
                cur_field[id(owner)] = fname
                if fname in ('vpiName', 'vpiFullName', 'vpiDecompile',
                             'vpiSize', 'vpiConstType', 'vpiOpType',
                             'vpiConstantSelect'):
                    owner.fields[fname] = fval
                    if fname == 'vpiFullName':
                        owner.fullname = fval
                    elif fname == 'vpiName' and not owner.name:
                        owner.name = fval
                mv = VAL.match(line)
                if mv:
                    owner.fields['VALUE'] = mv.group(2) + ':' + mv.group(3)
                continue
            # bare continuation lines (multi-line values) are ignored
    return out


def chain(n):
    """(type, field) pairs from the node up to the design root."""
    out = []
    p = n.parent
    while p is not None and p.type != 'DESIGN':
        out.append((p.type, p.field))
        p = p.parent
    return out


def named_ancestor(n):
    p = n.parent
    while p is not None and p.type != 'DESIGN':
        if p.fullname:
            return p.fullname
        p = p.parent
    return ''


def key(n):
    return (named_ancestor(n), n.sspan, n.fields.get('vpiDecompile', ''))


def ts_of(n):
    """The constant's typespec, as a comparable string: the ref_typespec's
    fullname plus the ACTUAL typespec's type and span."""
    for k in n.kids:
        if k.field == 'vpiTypespec':
            act = ''
            for k2 in k.kids:
                if k2.field == 'vpiActual':
                    act = '%s@%s' % (k2.type, k2.span)
            return 'ref_typespec(%s)->%s' % (k.fullname, act or '<none>')
    return ''


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '--selfcheck':
        # THE CONTROL, on the exact shape that broke r10earl30's reader: a
        # vpiConstType printed AFTER a nested ref_typespec subtree, and the
        # nested object's own fields must not leak into the constant.
        import tempfile, os
        txt = (
            "        \\_constant: , line:59:23, endln:59:27\n"
            "          |vpiDecompile:1\n"
            "          |vpiSize:3\n"
            "          |INT:1\n"
            "          |vpiTypespec:\n"
            "          \\_ref_typespec: (work@g1_ctx)\n"
            "            |vpiParent:\n"
            "            \\_constant: , line:59:23, endln:59:27\n"
            "            |vpiFullName:work@g1_ctx\n"
            "            |vpiActual:\n"
            "            \\_int_typespec: , line:59:14, endln:59:17\n"
            "          |vpiConstType:7\n")
        fd, p = tempfile.mkstemp()
        os.write(fd, txt.encode())
        os.close(fd)
        cs = [c for c in parse(p) if not c.stub]
        os.unlink(p)
        top = [c for c in cs if c.parent.type == 'DESIGN']
        ok = (len(top) == 1 and top[0].fields.get('vpiConstType') == '7'
              and top[0].fields.get('vpiSize') == '3'
              and top[0].fields.get('VALUE') == 'INT:1'
              and ts_of(top[0]) == 'ref_typespec(work@g1_ctx)->int_typespec@59:14-59:17')
        print('SELFCHECK reader: constants=%d top=%d ct=%r ts=%r' %
              (len(cs), len(top), top[0].fields.get('vpiConstType') if top else None,
               ts_of(top[0]) if top else None))
        print('SELFCHECK: %s (a vpiConstType AFTER a nested ref_typespec must be '
              'READ, the ref_typespec must be FOUND, and the stub constant under '
              'vpiParent must NOT be counted as a top-level constant)'
              % ('PASS' if ok else 'FAIL'))
        sys.exit(0 if ok else 1)
    for p in sys.argv[1:]:
        cs = parse(p)
        print(p, 'constants=%d' % len(cs),
              'with-ts=%d' % sum(1 for c in cs if ts_of(c)))
