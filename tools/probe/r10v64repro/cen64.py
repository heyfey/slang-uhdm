#!/usr/bin/env python3
"""r10v64 — INDEPENDENT positional constant census, read from a uhdm-dump.
Keyed on (nearest named ancestor, positional route of fields/indices), payload
= the Compare-visible fields only (vpiDecompile / vpiSize / value / vpiConstType
/ typespec actual kind).  vpiParent back-references and the weaklyReferenced
tail are skipped.  MEASUREMENT ONLY.
usage: cen64.py <dump.txt> [ref_obj|const]"""
import sys, re

WANT = sys.argv[2] if len(sys.argv) > 2 else 'const'
lines = open(sys.argv[1], errors='replace').read().splitlines()

# stack entries: (indent, kind, route, named, childcount dict)
stack = []
out = []
cur = None            # the constant record being filled
cur_indent = None
skip_indent = None    # inside a vpiParent back-reference
field_at = {}         # indent -> last field name seen at that indent

OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): *(.*)$')
FLD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
VAL = re.compile(r"^(\s*)\|(UINT|INT|HEX|BIN|OCT|DEC|STRING|REAL|SCAL):(.*)$")

def flush():
    global cur
    if cur is not None:
        out.append(cur[0] + ' || ' + ' '.join(cur[1]))
        cur = None

for ln in lines:
    if ln.startswith('\\_weaklyReferenced:'):
        break
    m = OBJ.match(ln)
    if m:
        ind = len(m.group(1)); kind = m.group(2)
        hdr = m.group(3).split(', file:')[0].split(', line:')[0]
        mn = re.search(r'\(([^)]*)\)', hdr); nm = mn.group(1) if mn else ''
        if skip_indent is not None and ind > skip_indent:
            continue
        skip_indent = None
        fld = field_at.get(ind, '?')
        if fld == 'vpiParent':
            skip_indent = ind
            continue
        flush()
        while stack and stack[-1][0] >= ind:
            stack.pop()
        parent = stack[-1] if stack else None
        if parent is None:
            route = kind; named = nm
        else:
            key = fld
            parent[4][key] = parent[4].get(key, -1) + 1
            route = parent[2] + '/' + fld + '[%d]' % parent[4][key]
            named = nm if nm else parent[3]
        stack.append([ind, kind, route, named, {}])
        if (WANT == 'const' and kind == 'constant') or \
           (WANT == 'ref_obj' and kind == 'ref_obj'):
            cur = ['%s %s %s' % (named, route, kind), []]
            cur_indent = ind
        continue
    m = FLD.match(ln)
    if m:
        ind = len(m.group(1)); fname = m.group(2); rest = m.group(3)
        if skip_indent is not None and ind > skip_indent:
            continue
        field_at[ind] = fname
        v = VAL.match(ln)
        if cur is not None and ind == cur_indent + 2:
            if v:
                cur[1].append('VALUE=%s:%s' % (v.group(2), v.group(3)))
            elif fname in ('vpiDecompile', 'vpiSize', 'vpiConstType', 'vpiName'):
                cur[1].append('%s=%s' % (fname, rest))
            elif fname == 'vpiTypespec':
                cur[1].append('TS=yes')
        continue
flush()
# the typespec ACTUAL kind: re-scan cheaply by pairing constants with the
# int_typespec/… line two levels down is unnecessary for the buckets we score.
for o in sorted(out):
    print(o)
