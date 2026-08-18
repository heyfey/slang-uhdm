#!/usr/bin/env python3
"""r10vrgg18repro/vcen18.py — VIEW-GENERAL parameter/param_assign census from a
uhdm-dump text.  Independent of the implementer's C++ instrument.

Emits one TSV record per (view, owner-scope, param-name, slot) with a
COMPARE-VISIBLE payload only:  vpiValue, vpiDecompile, vpiSize, vpiConstType,
vpiSigned, vpiConstantSelect, plus the RHS object KIND (constant vs operation
vs ref_obj -- "golden does not fold at all" is a distinguishable answer).
NO span, NO line/col, NO file.  Paths are normalised (work@ prefix dropped,
any /tmp/... workdir stripped).
"""
import re, sys, os

KNOWN_FIELDS = None  # any |Name:... where Name starts lowercase 'vpi' is a field

hdr = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+):\s*(?:\(([^)]*)\))?(.*)$')
fld = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')

def norm(s):
    if s is None:
        return ''
    s = re.sub(r'/tmp/[^ ,)]*', '<WD>', s)
    if s.startswith('work@'):
        s = s[5:]
    return s

def parse(path):
    objs = []            # list of dicts
    stack = []           # (indent, obj)
    with open(path, errors='replace') as f:
        for line in f:
            line = line.rstrip('\n')
            m = hdr.match(line)
            if m:
                ind = len(m.group(1))
                o = {'kind': m.group(2), 'fn': norm(m.group(3)), 'ind': ind,
                     'f': {}, 'val': '', 'children': [], 'parent': None}
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                if stack:
                    o['parent'] = stack[-1][1]
                    stack[-1][1]['children'].append(o)
                stack.append((ind, o))
                objs.append(o)
                continue
            m = fld.match(line)
            if m:
                ind = len(m.group(1))
                name, val = m.group(2), m.group(3)
                while stack and stack[-1][0] + 2 > ind:
                    if stack[-1][0] + 2 == ind:
                        break
                    stack.pop()
                if not stack:
                    continue
                o = stack[-1][1]
                if name.startswith('vpi'):
                    if val != '':
                        o['f'][name] = norm(val)
                else:
                    o['val'] = name + ':' + val
    return objs

def scopepath(o):
    # nearest ancestor with a fullname
    p = o
    while p is not None:
        fn = p['f'].get('vpiFullName') or p['fn']
        if fn:
            return fn
        p = p['parent']
    return '?'

def payload(o):
    keys = ['vpiSize', 'vpiConstType', 'vpiSigned', 'vpiDecompile',
            'vpiConstantSelect', 'vpiName', 'vpiDefName']
    d = ' '.join('%s=%s' % (k, o['f'][k]) for k in keys if k in o['f'])
    return ('VAL=%s ' % o['val'] if o['val'] else '') + d

def main():
    objs = parse(sys.argv[1])
    tag = sys.argv[2] if len(sys.argv) > 2 else 'X'
    out = []
    for o in objs:
        if o['kind'] == 'parameter' and o['f'].get('vpiName'):
            # only DECLARATION sites: the object that carries vpiLocalParam or
            # sits directly under a scope's vpiParameter list
            if o['parent'] is not None and o['parent']['kind'] in (
                    'ref_typespec', 'param_assign', 'operation', 'constant'):
                continue
            key = o['f'].get('vpiFullName') or (scopepath(o) + '.' + o['f']['vpiName'])
            out.append('%s\tPARAM\t%s\t%s' % (tag, key, payload(o)))
        if o['kind'] == 'param_assign':
            rhs = None
            lhs = None
            # children order follows the dump's field order
            for c in o['children']:
                if c['kind'] in ('constant', 'operation', 'ref_obj', 'hier_path',
                                 'sys_func_call', 'func_call', 'bit_select',
                                 'part_select', 'indexed_part_select',
                                 'var_select', 'enum_const'):
                    if rhs is None:
                        rhs = c
                if c['kind'] == 'parameter' and lhs is None:
                    lhs = c
            key = (lhs['f'].get('vpiFullName') or lhs['fn']) if lhs else (
                scopepath(o) + '.?')
            k = rhs['kind'] if rhs else '<none>'
            out.append('%s\tPA_RHS\t%s\t%s\t%s' % (
                tag, key, k, payload(rhs) if rhs else ''))
    for l in sorted(out):
        print(l)

main()
