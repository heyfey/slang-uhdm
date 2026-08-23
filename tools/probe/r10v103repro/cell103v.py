#!/usr/bin/env python3
"""r10v103repro/cell103v.py -- OWNER-KEYED CELL CENSUS over a uhdm-dump.

MEASUREMENT ONLY (the official uhdm-cmp is the judge).  Parses the indented
`uhdm-dump` text into a tree, then for every `function`/`task` object emits ONE
row:  <owner-name> TAB <canonical body>, where the body is the vpiStmt /
vpiStmts subtree rendered with Compare-VISIBLE material only -- object KIND,
vpiName, vpiDefName, the field name it hangs off -- and NO span, NO file, NO
vpiFullName, NO vpiParent back-reference subtree.  That makes a golden row and
an ours row directly comparable, and keeps the DEF/ELAB view out of the key.
"""
import sys, re

OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): ?(.*)$')
FLD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
NAME = re.compile(r'^([^,]*?)(?:, (?:file|line|endln):.*)?$')

def parse(lines):
    root = {'kind': 'ROOT', 'name': '', 'fields': [], 'indent': -1}
    stack = [root]
    pending = None            # field name the next object hangs off
    for ln in lines:
        m = OBJ.match(ln)
        if m:
            ind = len(m.group(1))
            while stack and stack[-1]['indent'] >= ind:
                stack.pop()
            node = {'kind': m.group(2), 'name': '', 'defname': '',
                    'fields': [], 'indent': ind}
            rest = m.group(3)
            nm = re.match(r'^\s*([^,(]*)\s*(?:\(([^)]*)\))?', rest)
            if nm:
                node['name'] = (nm.group(2) or nm.group(1) or '').strip()
            parent = stack[-1] if stack else root
            parent['fields'].append((pending or '?', node))
            stack.append(node)
            pending = None
            continue
        m = FLD.match(ln)
        if m:
            ind = len(m.group(1))
            while stack and stack[-1]['indent'] >= ind:
                stack.pop()
            fname, val = m.group(2), m.group(3).strip()
            if val:
                (stack[-1] if stack else root)['fields'].append((fname, val))
                pending = None
            else:
                pending = fname
            continue
        pending = None
    return root

SKIP_FIELDS = {'vpiParent', 'vpiFullName', 'vpiFile', 'vpiInstance',
               'vpiClassDefn', 'vpiTypedefAlias'}

def render(node, depth=0, maxd=40):
    if depth > maxd:
        return '...'
    parts = [node['kind']]
    if node['name']:
        parts.append('(' + node['name'] + ')')
    kids = []
    for fn, v in node['fields']:
        if fn in SKIP_FIELDS:
            continue
        if isinstance(v, str):
            if fn in ('vpiName', 'vpiDefName', 'vpiDecompile', 'vpiValue',
                      'vpiOpType', 'vpiConstType', 'vpiDirection', 'vpiSize'):
                kids.append('%s=%s' % (fn, v))
        else:
            kids.append('%s{%s}' % (fn, render(v, depth + 1, maxd)))
    if kids:
        return ' '.join(parts) + '[' + ' '.join(sorted(kids)) + ']'
    return ' '.join(parts)

def walk(node, out):
    if node['kind'] in ('function', 'task'):
        body = []
        for fn, v in node['fields']:
            if fn in ('vpiStmt', 'vpiStmts') and not isinstance(v, str):
                body.append(fn + '{' + render(v) + '}')
        nm = node['name'].split('::')[-1]
        out.append((nm, ' '.join(body) if body else '<no-stmt>'))
    for fn, v in node['fields']:
        if isinstance(v, str) or fn == 'vpiParent':
            continue
        walk(v, out)

def main():
    lines = open(sys.argv[1], errors='replace').read().splitlines()
    root = parse(lines)
    out = []
    walk(root, out)
    seen = {}
    for nm, body in out:
        seen.setdefault(nm, []).append(body)
    for nm in sorted(seen):
        bodies = sorted(seen[nm])
        print('%s\tn=%d\t%s' % (nm, len(bodies), ' || '.join(sorted(set(bodies)))))

main()
