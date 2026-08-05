#!/usr/bin/env python3
"""Every ref_typespec whose PARENT is an expression node, with that parent's
kind + span and the enclosing function/package/module.

usage: argts.py <dump>

Written for the func-call-argument typespec class (r10earl6 pp.sv): the stamp
is invisible in a parameter projection and buried in a 3000-line dump.
"""
import re, sys

lines = open(sys.argv[1]).read().splitlines()
stack = []
out = []
for ln in lines:
    m = re.match(r'^(\s*)\\_(\w+): ?(\([^)]*\))?,? ?(.*)$', ln)
    if not m:
        continue
    ind, kind, nm, rest = len(m.group(1)), m.group(2), (m.group(3) or ''), m.group(4)
    loc = ''
    lm = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', rest)
    if lm:
        loc = lm.group(1) + '..' + lm.group(2)
    while stack and stack[-1][0] >= ind:
        stack.pop()
    stack.append((ind, kind, nm.strip('()'), loc))
    if kind != 'ref_typespec':
        continue
    if len(stack) < 2:
        continue
    par = stack[-2]
    if par[1] not in ('operation', 'part_select', 'ref_obj', 'bit_select',
                      'constant', 'indexed_part_select'):
        continue
    owner = ''
    for e in reversed(stack[:-2]):
        if e[1] in ('function', 'task', 'module_inst', 'package'):
            owner = e[1] + ':' + e[2]
            break
    print('%-34s %-14s %-16s ts=%s' % (owner, par[1], par[3], nm.strip('()')))
