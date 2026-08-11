#!/usr/bin/env python3
"""r10uvm52repro/dumptree.py — parse a uhdm-dump text tree into a real tree so
questions like "which RELATION holds this ref_obj, and what SUBROUTINE contains
it" become MEASUREMENTS instead of grep impressions.

LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  This script reads ONE dump;
the caller runs it on both sides.

The dump's FIRST LINE is the DATABASE PATH and always differs between the two
sides, so every driver in this campaign pipes dumps through `sed '1d'`.  This
parser tolerates either (a leading non-`\\_` line is ignored).

GUARDS
  * refuses to report on a file it could not parse into at least one node
    (a driver that reaches nothing must never read as perfection);
  * `--selftest` is the POSITIVE CONTROL: it parses a tiny built-in fixture and
    asserts the relation/ancestor answers, so a silently-broken parser cannot
    report zero findings.

Usage:
  dumptree.py <dump> actualkinds <NodeKind>      # histogram of vpiActual targets
  dumptree.py <dump> boundby <TargetKind>        # relation+ancestor census of
                                                 # every ref_obj whose vpiActual
                                                 # is a <TargetKind>
  dumptree.py <dump> refs <regex>                # every ref_obj whose name
                                                 # matches, with rel/actual/scope
  dumptree.py --selftest
"""
import re
import sys

NODE = re.compile(r'^(\s*)\\_([a-z_0-9]+): (.*)$')
PROP = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')


class Node:
    __slots__ = ('kind', 'text', 'rel', 'parent', 'kids', 'props')

    def __init__(self, kind, text, rel, parent):
        self.kind = kind
        self.text = text
        self.rel = rel          # relation name under which the PARENT holds us
        self.parent = parent
        self.kids = []
        self.props = {}

    def name(self):
        m = re.match(r'^\(([^)]*)\)', self.text)
        return m.group(1) if m else ''

    def loc(self):
        m = re.search(r'line:(\d+):(\d+)', self.text)
        return '%s:%s' % (m.group(1), m.group(2)) if m else '?'

    def child(self, rel):
        for k in self.kids:
            if k.rel == rel:
                return k
        return None

    def ancestors(self):
        p = self.parent
        while p is not None:
            yield p
            p = p.parent


def parse(lines):
    """Build the tree.  vpiParent back-edges are DROPPED (they would make the
    'tree' cyclic and would double-count every node)."""
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
            pending_rel = None
            continue                       # back-edge, not a child
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


def scope_of(n):
    for a in n.ancestors():
        if a.kind in ('function', 'task'):
            return a
    return None


def container_of(sub):
    """package / class_defn / module_inst that owns a function|task."""
    if sub is None:
        return None
    for a in sub.ancestors():
        if a.kind in ('class_defn', 'package', 'module_inst', 'design'):
            return a
    return None


def cmd_boundby(root, target):
    rows = {}
    total = 0
    for n in walk(root):
        if n.kind != 'ref_obj':
            continue
        act = n.child('vpiActual')
        if act is None or act.kind != target:
            continue
        total += 1
        sub = scope_of(n)
        cont = container_of(sub)
        key = (n.rel or '<none>', cont.kind if cont else '<none>')
        rows[key] = rows.get(key, 0) + 1
    if total == 0:
        print('UNMEASURED: no ref_obj with vpiActual -> %s in this dump' % target)
        return
    print('ref_obj -> vpiActual -> %s : %d total' % (target, total))
    print('%-22s %-14s %s' % ('RELATION', 'SUB CONTAINER', 'COUNT'))
    for k in sorted(rows, key=lambda k: -rows[k]):
        print('%-22s %-14s %d' % (k[0], k[1], rows[k]))


def cmd_actualkinds(root, kind):
    rows = {}
    for n in walk(root):
        if n.kind != kind:
            continue
        act = n.child('vpiActual')
        rows[act.kind if act else '<none>'] = rows.get(
            act.kind if act else '<none>', 0) + 1
    if not rows:
        print('UNMEASURED: no %s nodes in this dump' % kind)
        return
    for k in sorted(rows, key=lambda k: -rows[k]):
        print('%-24s %d' % (k, rows[k]))


def cmd_reftab(root):
    """One deduped line per DISTINCT ref_obj identity, so the two sides can be
    `comm`-ed.  A dump prints the same object many times; the key is
    (loc, fullname, relation, subroutine, container-kind) and the VALUE is the
    kind of its vpiActual (or NONE).  Deduped because a repeated printing is
    not a second object."""
    seen = set()
    for n in walk(root):
        if n.kind != 'ref_obj':
            continue
        act = n.child('vpiActual')
        sub = scope_of(n)
        cont = container_of(sub)
        # CTX = parent kind [/ grandparent kind]: the axis that decides whether
        # a call argument sits under a RECEIVER-qualified call
        # (method_func_call under a hier_path) or a bare func_call.
        par = n.parent
        gpar = par.parent if par else None
        ctx = '%s/%s' % (par.kind if par else '-', gpar.kind if gpar else '-')
        seen.add('%s|%s|%s|%s|%s|%s|%s' % (
            n.loc(), n.props.get('vpiFullName', n.name()), n.rel or '-',
            sub.name() if sub else '-', cont.kind if cont else '-',
            act.kind if act else 'NONE', ctx))
    if not seen:
        print('UNMEASURED: no ref_obj in this dump')
        return
    for l in sorted(seen):
        print(l)


def cmd_hpargs(root):
    """Every ARGUMENT ref_obj of a method_func_call/method_task_call that hangs
    under a hier_path — the receiver-qualified call.  Prints the hier_path's own
    vpiName (the RECEIVER text) beside the bind verdict, because the candidate
    distinguisher is what the receiver resolves to."""
    rows = {}
    n = 0
    for x in walk(root):
        if x.kind != 'ref_obj' or x.rel != 'vpiArgument':
            continue
        par = x.parent
        if par is None or par.kind not in ('method_func_call',
                                           'method_task_call'):
            continue
        gp = par.parent
        if gp is None or gp.kind != 'hier_path':
            continue
        act = x.child('vpiActual')
        sub = scope_of(x)
        cont = container_of(sub)
        n += 1
        rows['%s|%s|%s|%s|%s|%s' % (
            x.loc(), x.name(), gp.props.get('vpiName', '?'),
            act.kind if act else 'NONE', sub.name() if sub else '-',
            cont.kind if cont else '-')] = 1
    if n == 0:
        print('UNMEASURED: no method-call arguments under a hier_path')
        return
    for l in sorted(rows):
        print(l)


def cmd_refs(root, pat):
    rx = re.compile(pat)
    hits = 0
    for n in walk(root):
        if n.kind != 'ref_obj':
            continue
        nm = n.props.get('vpiFullName', n.name())
        if not rx.search(nm):
            continue
        hits += 1
        act = n.child('vpiActual')
        sub = scope_of(n)
        cont = container_of(sub)
        print('%-58s @%-10s rel=%-16s actual=%-16s sub=%s in %s' % (
            nm[:58], n.loc(), n.rel or '-',
            (act.kind + '(' + act.loc() + ')') if act else 'NONE',
            (sub.name() if sub else '-'),
            (cont.kind if cont else '-')))
    if hits == 0:
        print('UNMEASURED: no ref_obj matched /%s/' % pat)


SELFTEST = r'''
\_design: (work@x)
  |vpiTopModule:
  \_module_inst: (work@t)
    |vpiTask:
    \_function: (f)
      |vpiParent:
      \_module_inst: (work@t)
      |vpiStmt:
      \_assignment: , line:3:1, endln:3:9
        |vpiRhs:
        \_ref_obj: (a), line:3:5, endln:3:6
          |vpiParent:
          \_assignment: , line:3:1, endln:3:9
          |vpiFullName:t::f::a
          |vpiActual:
          \_io_decl: (a), line:2:5, endln:2:6
        |vpiLhs:
        \_ref_obj: (b), line:3:1, endln:3:2
          |vpiFullName:t::f::b
'''


def selftest():
    root = parse(SELFTEST.strip('\n').split('\n'))
    nodes = list(walk(root))
    kinds = [n.kind for n in nodes]
    assert kinds.count('module_inst') == 1, kinds   # vpiParent back-edge dropped
    assert kinds.count('function') == 1, kinds
    refs = [n for n in nodes if n.kind == 'ref_obj']
    assert len(refs) == 2, refs
    a = [r for r in refs if r.name() == 'a'][0]
    b = [r for r in refs if r.name() == 'b'][0]
    assert a.rel == 'vpiRhs', a.rel
    assert b.rel == 'vpiLhs', b.rel
    assert a.child('vpiActual').kind == 'io_decl'
    assert b.child('vpiActual') is None
    assert scope_of(a).name() == 'f'
    assert container_of(scope_of(a)).kind == 'module_inst'
    print('SELFTEST OK: 2 ref_obj, relations vpiRhs/vpiLhs, 1 io_decl actual, '
          'scope f in module_inst, vpiParent back-edges dropped')


def main():
    if len(sys.argv) == 2 and sys.argv[1] == '--selftest':
        selftest()
        return 0
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    path, cmd = sys.argv[1], sys.argv[2]
    try:
        with open(path) as f:
            lines = f.read().split('\n')
    except OSError as e:
        print('FATAL: cannot read %s: %s' % (path, e))
        return 3
    root = parse(lines)
    n = sum(1 for _ in walk(root))
    if n == 0:
        print('FATAL: parsed 0 nodes from %s — REFUSING TO REPORT' % path)
        return 5
    sys.stderr.write('parsed %d nodes from %s\n' % (n, path))
    if cmd == 'boundby':
        cmd_boundby(root, sys.argv[3])
    elif cmd == 'actualkinds':
        cmd_actualkinds(root, sys.argv[3])
    elif cmd == 'hpargs':
        cmd_hpargs(root)
    elif cmd == 'reftab':
        cmd_reftab(root)
    elif cmd == 'refs':
        cmd_refs(root, sys.argv[3])
    else:
        print('FATAL: unknown command %s' % cmd)
        return 2
    return 0


if __name__ == '__main__':
    sys.exit(main())
