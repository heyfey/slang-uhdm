#!/usr/bin/env python3
"""View-general cell census of a uhdm-dump.

Emits one TSV line per constant/operation/ref_obj/call object:
  VIEW  loc  kind  payload  parentkind
VIEW is the top-level design container the object lives under
(uhdmallPackages / uhdmtopPackages / uhdmallModules / ...), so the
comparator is view-general: the same source cell in two views is two rows.
Payload carries exactly the fields the generated Compare bodies read for
these kinds (VpiDecompile / VpiSize / Typespec presence / VpiOpType /
VpiName / VpiConstType) plus the raw value string for diagnosis.
Locations are source-derived, so they are stable across implementations.
"""
import sys, re

KINDS = ('constant', 'operation', 'ref_obj', 'func_call', 'method_func_call',
         'sys_func_call', 'bit_select', 'part_select',
         'indexed_part_select', 'hier_path', 'return_stmt', 'var_select')
VIEWRE = re.compile(r'^\|(uhdm[A-Za-z]+):\s*$')
LOCRE = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')

def parse(path):
    objs = []
    stack = []          # (indent, objid)
    curfield = None
    view = '-'
    with open(path, 'rt', errors='replace') as f:
        for ln, line in enumerate(f):
            line = line.rstrip('\n')
            m = VIEWRE.match(line)
            if m:
                view = m.group(1); stack = []; curfield = None
                continue
            s = line.lstrip(' ')
            indent = len(line) - len(s)
            if s.startswith('\\_'):
                body = s[2:]
                kind = body.split(':', 1)[0]
                while stack and stack[-1][0] >= indent:
                    stack.pop()
                parent = stack[-1][1] if stack else None
                o = dict(id=len(objs), kind=kind, header=body, indent=indent,
                         parent=parent, fields={}, view=view, slot=curfield)
                objs.append(o)
                stack.append((indent, o['id']))
            elif s.startswith('|'):
                body = s[1:]
                k, _, v = body.partition(':')
                curfield = k
                owner = None
                for i in range(len(stack) - 1, -1, -1):
                    if stack[i][0] < indent:
                        owner = stack[i][1]; break
                if owner is not None:
                    objs[owner]['fields'].setdefault(k, []).append(v)
    return objs

def loc(o):
    m = LOCRE.search(o['header'])
    return '%s:%s-%s:%s' % m.groups() if m else 'NOLOC'

def main(path):
    objs = parse(path)
    # vpiParent back-edges are rendered as child objects: drop them
    out = []
    for o in objs:
        if o['slot'] == 'vpiParent':
            continue
        if o['kind'] not in KINDS:
            continue
        f = o['fields']
        pay = []
        for k in ('vpiOpType', 'vpiName', 'vpiDefName', 'vpiDecompile',
                  'vpiSize', 'vpiConstType', 'vpiFuncType'):
            if k in f:
                pay.append('%s=%s' % (k, f[k][0]))
        for k in f:
            if k in ('INT', 'UINT', 'REAL', 'BIN', 'DEC', 'HEX', 'OCT',
                     'STRING', 'SCAL'):
                pay.append('VAL=%s:%s' % (k, f[k][0]))
        pay.append('ts=%d' % (1 if 'vpiTypespec' in f else 0))
        par = objs[o['parent']] if o['parent'] is not None else None
        # walk past vpiParent back-edge shells
        pk = par['kind'] if par else '-'
        out.append('%s\t%s\t%s\t%s\tpar=%s\tslot=%s' %
                   (o['view'], loc(o), o['kind'], ' '.join(sorted(pay)), pk,
                    o['slot']))
    for l in sorted(out):
        print(l)

main(sys.argv[1])
