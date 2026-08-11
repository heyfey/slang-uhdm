#!/usr/bin/env python3
"""r10uvm54repro/clsparam.py — the CLASS VALUE PARAMETER typespec instrument.

LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  Reads ONE dump; the caller
runs it on both sides and joins with `join.py`-style keys.

For every `parameter` node whose vpiParent is a `class_defn` it prints

    <class>::<param>  occ=N  kind=<vpiActual typespec kind>  span=<its span>

keyed by (class, param) and UNIONed over occurrences, because uhdm-dump prints
an object's children at some occurrences and abbreviates it at others.

The owner is taken from the object's OWN vpiParent back-edge (captured, not
followed) and NOT from the printed enclosing node: a class_defn is printed under
many owners and the parameter list is printed wherever the class_defn is.

GUARDS
  * exits 4 with `UNMEASURED:` when it finds no class_defn parameter at all;
  * prints UNMEASURED for any unresolvable field and counts those rows;
  * `--selftest` is the POSITIVE CONTROL (an object printed once detailed and
    once abbreviated, plus one with no typespec at all).  NEGATIVE CONTROL:
    replacing the `.add(` union with an assignment makes it FAIL (documented at
    the UNION comment).

Usage:
  clsparam.py <dump> rows [<regex>]
  clsparam.py <dump> kinds            # histogram of typespec kinds
  clsparam.py --selftest
"""
import re
import sys

NODE = re.compile(r'^(\s*)\\_([a-z_0-9]+): (.*)$')
PROP = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
UNMEAS = 'UNMEASURED'


class Node:
    __slots__ = ('kind', 'text', 'rel', 'parent', 'kids', 'props')

    def __init__(self, kind, text, rel, parent):
        self.kind = kind
        self.text = text
        self.rel = rel
        self.parent = parent
        self.kids = []
        self.props = {}

    def name(self):
        m = re.match(r'^\(([^)]*)\)', self.text)
        return m.group(1) if m else ''

    def span(self):
        m = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', self.text)
        return '%s:%s-%s:%s' % m.groups() if m else ''

    def child(self, rel):
        for k in self.kids:
            if k.rel == rel:
                return k
        return None


def parse(lines):
    root = Node('ROOT', '', None, None)
    stack = [(-1, root)]
    pending_rel = None
    pending_indent = None
    for ln in lines:
        m = PROP.match(ln)
        if m:
            ind, key, val = len(m.group(1)), m.group(2), m.group(3)
            if val.strip():
                while len(stack) > 1 and stack[-1][0] >= ind:
                    stack.pop()
                stack[-1][1].props[key] = val.strip()
                pending_rel = None
            else:
                pending_rel = key
                pending_indent = ind
            continue
        m = NODE.match(ln)
        if not m:
            continue
        ind = len(m.group(1))
        kind, text = m.group(2), m.group(3)
        if pending_rel == 'vpiParent' and pending_indent == ind:
            m2 = re.match(r'^\(([^)]*)\)', text)
            stack[-1][1].props['_PARENT'] = '%s %s' % (
                kind, m2.group(1) if m2 else '')
            pending_rel = None
            continue
        while len(stack) > 1 and stack[-1][0] >= ind:
            stack.pop()
        n = Node(kind, text, pending_rel, stack[-1][1])
        stack[-1][1].kids.append(n)
        stack.append((ind, n))
        pending_rel = None
    return root


def walk(n):
    for k in n.kids:
        yield k
        for x in walk(k):
            yield x


def collect(root):
    rows = {}
    for n in walk(root):
        if n.kind != 'parameter':
            continue
        own = n.props.get('_PARENT', '')
        if not own.startswith('class_defn '):
            continue
        cls = own[len('class_defn '):]
        key = (cls, n.props.get('vpiName', n.name()))
        r = rows.setdefault(key, {'occ': 0, 'kind': set(), 'span': set(),
                                  'pspan': set()})
        r['occ'] += 1
        if n.span():
            r['pspan'].add(n.span())
        # UNION over occurrences.  NEGATIVE CONTROL: turn the three `.add(...)`
        # calls here into assignments and --selftest fails.
        rt = n.child('vpiTypespec')
        if rt is not None:
            act = rt.child('vpiActual')
            if act is not None:
                r['kind'].add(act.kind)
                r['span'].add(act.span())
    return rows


def fld(sv):
    if not sv:
        return UNMEAS
    if len(sv) == 1:
        return next(iter(sv))
    return 'CONFLICT{' + '|'.join(sorted(sv)) + '}'


SELFTEST = r"""
\_design: (work@t)
  |vpiClassDefn:
  \_class_defn: (p::a)
    |vpiParameter:
    \_parameter: (p::a::S), line:1:20, endln:1:25
      |vpiParent:
      \_class_defn: (p::a)
      |vpiName:S
      |vpiTypespec:
      \_ref_typespec: (p::a::S)
        |vpiActual:
        \_string_typespec: , line:1:13, endln:1:19
    |vpiParameter:
    \_parameter: (p::a::N), line:2:20, endln:2:21
      |vpiParent:
      \_class_defn: (p::a)
      |vpiName:N
  |vpiModule:
  \_module_inst: (work@t)
    |vpiParameter:
    \_parameter: (p::a::S), line:1:20, endln:1:25
      |vpiParent:
      \_class_defn: (p::a)
      |vpiName:S
"""


def selftest():
    rows = collect(parse(SELFTEST.split('\n')))
    ok = True

    def chk(c, m):
        nonlocal ok
        if not c:
            print('SELFTEST FAIL: ' + m)
            ok = False

    chk(len(rows) == 2, 'expected 2 class parameters, got %d' % len(rows))
    S = rows.get(('p::a', 'S'))
    N = rows.get(('p::a', 'N'))
    chk(S is not None and S['occ'] == 2,
        'the abbreviated re-print must be UNIONed into one row, not a new one')
    chk(S is not None and fld(S['kind']) == 'string_typespec',
        'union of occurrences lost the typespec kind (got %s)'
        % (fld(S['kind']) if S else 'no row'))
    chk(S is not None and fld(S['span']) == '1:13-1:19',
        'typespec span parse wrong')
    chk(N is not None and fld(N['kind']) == UNMEAS,
        'a parameter with NO vpiTypespec must read UNMEASURED, not blank')
    print('SELFTEST %s' % ('PASS' if ok else 'FAIL'))
    return 0 if ok else 1


def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--selftest':
        sys.exit(selftest())
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(2)
    path, cmd = sys.argv[1], sys.argv[2]
    pat = re.compile(sys.argv[3]) if len(sys.argv) > 3 else None
    with open(path, 'rt', errors='replace') as f:
        rows = collect(parse(f.read().split('\n')))
    if not rows:
        print('UNMEASURED: no class_defn-owned `parameter` in %s (the '
              'instrument reached NOTHING)' % path)
        sys.exit(4)
    if cmd == 'rows':
        unm = 0
        for k in sorted(rows):
            r = rows[k]
            if pat and not (pat.search(k[0]) or pat.search(k[1])):
                continue
            line = '%-58s occ=%-4d kind=%-22s span=%-22s pspan=%s' % (
                k[0] + '::' + k[1], r['occ'], fld(r['kind']), fld(r['span']),
                fld(r['pspan']))
            if UNMEAS in line:
                unm += 1
            print(line)
        print('-- class parameters=%d  rows with an UNMEASURED field=%d'
              % (len(rows), unm))
    elif cmd == 'kinds':
        h = {}
        for r in rows.values():
            h[fld(r['kind'])] = h.get(fld(r['kind']), 0) + 1
        for k in sorted(h, key=lambda x: -h[x]):
            print('%-24s %d' % (k, h[k]))
        print('-- total class parameters=%d' % len(rows))
    else:
        print('unknown cmd')
        sys.exit(2)


main()
