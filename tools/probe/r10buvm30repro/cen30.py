#!/usr/bin/env python3
"""Census of unary-minus / negative-constant cells in a uhdm-dump text tree.

The dump is an indented tree: '\\_<kind>: ...' opens an object at its indent,
'|<field>:...' is a field of the object whose indent is one less... actually
fields appear at the SAME indent as the '\\_' of their children.  We rebuild the
nesting from the indent column alone.
"""
import sys, re

def parse(path):
    # returns list of (indent, kind, header, [fields]) with a parent link
    objs = []          # id -> dict
    stack = []         # (indent, objid)
    cur = None
    curfield = None
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
                cur = o
            elif s.startswith('|'):
                body = s[1:]
                k, _, v = body.partition(':')
                curfield = k
                while stack and stack[-1][0] > indent:
                    stack.pop()
                # the field belongs to the object at indent-2 (its '\_' col)
                owner = None
                for i in range(len(stack) - 1, -1, -1):
                    if stack[i][0] < indent:
                        owner = stack[i][1]
                        break
                if owner is not None:
                    objs[owner]['fields'].setdefault(k, []).append(v)
    return objs

LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')

def loc(o):
    m = LOC.search(o['header'])
    return '%s:%s-%s:%s' % m.groups() if m else '?'

if __name__ == '__main__':
    objs = parse(sys.argv[1])
    what = sys.argv[2] if len(sys.argv) > 2 else 'both'
    if what in ('both', 'neg'):
        for o in objs:
            if o['kind'] != 'constant':
                continue
            d = o['fields'].get('vpiDecompile', [''])[0]
            if d.startswith('-'):
                p = objs[o['parent']] if o['parent'] is not None else None
                print('NEG\t%s\t%s\tsz=%s\tct=%s\tval=%s\tslot=%s\tparent=%s@%s' % (
                    loc(o), d,
                    o['fields'].get('vpiSize', ['?'])[0],
                    o['fields'].get('vpiConstType', ['?'])[0],
                    ','.join(v for k, v in o['fields'].items()
                             if k in ('INT', 'UINT') for v in [o['fields'][k][0]]),
                    o['slot'],
                    p['kind'] if p else '-', loc(p) if p else '-'))
    if what in ('both', 'op'):
        for o in objs:
            if o['kind'] != 'operation':
                continue
            if o['fields'].get('vpiOpType', [''])[0] != '1':
                continue
            kids = [objs[k] for k in o['kids'] if objs[k]['slot'] == 'vpiOperand']
            kk = ';'.join('%s@%s%s' % (k['kind'], loc(k),
                                       '[' + k['fields'].get('vpiDecompile', [''])[0] + ']'
                                       if k['kind'] == 'constant' else '')
                          for k in kids)
            p = objs[o['parent']] if o['parent'] is not None else None
            print('MINUSOP\t%s\tnops=%d\t%s\tslot=%s\tparent=%s@%s' % (
                loc(o), len(kids), kk, o['slot'],
                p['kind'] if p else '-', loc(p) if p else '-'))
