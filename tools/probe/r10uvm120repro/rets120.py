#!/usr/bin/env python3
"""r10uvm120 — per-VIEW, per-SUBROUTINE rendering of every return_stmt's
condition subtree in a uhdm-dump text tree.  MEASUREMENT ONLY (the official
uhdm-cmp is the judge).

Key = <view>|<enclosing subroutine fullname>|<return span>, so a cell survives
line-number churn between arms and is comparable golden-vs-ours.  The rendered
body carries exactly the fields a constant/ref_obj compare reads, plus the
PARENT kind and the typespec ACTUAL kind+span (parent and span are dump-only;
they are printed because this pass's law is about them).
    rets120.py <dump>
"""
import sys, re

LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


def parse(path):
    objs, stack, curfield = [], [], None
    with open(path, 'rt', errors='replace') as f:
        for ln, line in enumerate(f):
            line = line.rstrip('\n')
            s = line.lstrip(' ')
            indent = len(line) - len(s)
            if s.startswith('\\_'):
                body = s[2:]
                kind = body.split(':', 1)[0]
                while stack and stack[-1][0] >= indent:
                    stack.pop()
                parent = stack[-1][1] if stack else None
                o = dict(id=len(objs), kind=kind, header=body, indent=indent,
                         parent=parent, fields={}, kids=[], line=ln + 1,
                         slot=curfield)
                objs.append(o)
                if parent is not None:
                    objs[parent]['kids'].append(o['id'])
                stack.append((indent, o['id']))
            elif s.startswith('|'):
                k, _, v = s[1:].partition(':')
                curfield = k
                while stack and stack[-1][0] > indent:
                    stack.pop()
                owner = None
                for i in range(len(stack) - 1, -1, -1):
                    if stack[i][0] < indent:
                        owner = stack[i][1]
                        break
                if owner is not None:
                    objs[owner]['fields'].setdefault(k, []).append(v)
    return objs


def loc(o):
    m = LOC.search(o['header'])
    return '%s:%s-%s:%s' % m.groups() if m else '?'


FIELDS = ('vpiOpType', 'vpiName', 'vpiDecompile', 'vpiSize', 'vpiConstType',
          'INT', 'UINT', 'REAL', 'STRING', 'DEC', 'HEX', 'BIN', 'SCAL')
FOLLOW = ('vpiOperand', 'vpiIndex', 'vpiCondition', 'vpiArgument', 'vpiExpr',
          'vpiLeftRange', 'vpiRightRange')


def render(objs, o, depth, out):
    f = o['fields']
    bits = ['%s@%s' % (o['kind'], loc(o))]
    for k in FIELDS:
        if k in f:
            bits.append('%s=%s' % (k, f[k][0]))
    p = objs[o['parent']] if o['parent'] is not None else None
    # the dump prints vpiParent as a CHILD row; prefer that
    for k in o['kids']:
        if objs[k]['slot'] == 'vpiParent':
            p = objs[k]
            break
    bits.append('par=%s' % (('%s@%s' % (p['kind'], loc(p))) if p else '-'))
    ts = '-'
    for k in o['kids']:
        c = objs[k]
        if c['slot'] == 'vpiTypespec':
            for g in c['kids']:
                if objs[g]['slot'] == 'vpiActual':
                    ts = '%s@%s' % (objs[g]['kind'], loc(objs[g]))
            if ts == '-':
                ts = 'EMPTYREF'
    bits.append('ts=%s' % ts)
    act = '-'
    for k in o['kids']:
        c = objs[k]
        if c['slot'] == 'vpiActual' and o['kind'] == 'ref_obj':
            act = '%s@%s' % (c['kind'], loc(c))
    bits.append('act=%s' % act)
    out.append('  ' * depth + ' '.join(bits))
    for k in o['kids']:
        c = objs[k]
        if c['slot'] in FOLLOW:
            render(objs, c, depth + 1, out)
    return out


def main(path):
    objs = parse(path)
    # view boundaries
    views = []
    with open(path, 'rt', errors='replace') as f:
        for ln, line in enumerate(f):
            if line.startswith('|uhdm'):
                views.append((ln + 1, line.strip().lstrip('|').rstrip(':')))
    def view_of(ln):
        v = 'PRE'
        for s, n in views:
            if s <= ln:
                v = n
        return v
    rows = []
    for o in objs:
        if o['kind'] != 'return_stmt':
            continue
        # enclosing subroutine
        owner, p = '?', o['parent']
        while p is not None:
            q = objs[p]
            if q['kind'] in ('function', 'task'):
                owner = q['fields'].get('vpiFullName', ['?'])[0]
                break
            p = q['parent']
        for k in o['kids']:
            c = objs[k]
            if c['slot'] != 'vpiCondition':
                continue
            body = '\n'.join(render(objs, c, 1, []))
            rows.append('%s|%s|%s\n%s' % (view_of(o['line']), owner, loc(o),
                                          body))
    seen = set()
    for r in rows:
        if r in seen:
            continue
        seen.add(r)
        print(r)


if __name__ == '__main__':
    main(sys.argv[1])
