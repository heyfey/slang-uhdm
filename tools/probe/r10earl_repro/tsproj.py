#!/usr/bin/env python3
"""Project a uhdm-dump onto "<view-ish path>  <owner kind> '<name>' -> <ts kind> loc".

usage: tsproj.py <dump> [name-regex]

Walks the indentation tree, remembering the innermost `port`/`logic_net`/
`logic_var`/`array_var`/`array_net` ancestor, and prints every `vpiTypespec:`
ref_typespec's ACTUAL kind + span underneath it.  Built for the
array_typespec-vs-logic_typespec census (r10earl6).
"""
import re, sys

dump = open(sys.argv[1]).read().splitlines()
pat = re.compile(sys.argv[2]) if len(sys.argv) > 2 else None

OWNERS = ('port', 'logic_net', 'logic_var', 'array_var', 'array_net',
          'bit_var', 'int_var', 'enum_var', 'struct_var', 'packed_array_var',
          'packed_array_net', 'byte_var')

stack = []   # (indent, kind, name, loc)
out = []
for ln in dump:
    m = re.match(r'^(\s*)\\_(\w+): (\([^)]*\))?,? ?(.*)$', ln)
    if not m:
        continue
    ind, kind, nm, rest = len(m.group(1)), m.group(2), m.group(3) or '', m.group(4)
    loc = ''
    lm = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', rest)
    if lm:
        loc = lm.group(1) + '..' + lm.group(2)
    while stack and stack[-1][0] >= ind:
        stack.pop()
    stack.append((ind, kind, nm.strip('()'), loc))
    if kind in ('array_typespec', 'logic_typespec', 'bit_typespec',
                'int_typespec', 'struct_typespec', 'enum_typespec',
                'packed_array_typespec'):
        own = None
        for e in reversed(stack[:-1]):
            if e[1] in OWNERS:
                own = e
                break
        if own is None:
            continue
        if pat and not pat.search(own[2]):
            continue
        chain = '/'.join(e[1] + (':' + e[2] if e[2] else '')
                         for e in stack[:-1] if e[1] in
                         ('design', 'module_inst', 'package') or e is own)
        out.append('%-58s %-22s %s' % (chain, kind, loc))
for o in out:
    print(o)
