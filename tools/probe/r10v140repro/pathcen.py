#!/usr/bin/env python3
# r10v140 (VERIFIER) — BROAD dump census: EVERY |vpiActual: binding in the
# database, keyed by the PATH of enclosing objects+fields (so a class property,
# a method formal, a local, a typedef listing entry and a return are all cells).
# Values carry kind+name only (no file/line/span: our objects carry no file, and
# spans are not Compare-visible).  Sorted MULTISET per key.
# MEASUREMENT ONLY.  LHS IS ALWAYS GOLDEN.
import sys, re, collections
def clean(s):
    s = re.sub(r', (line|file|endln|col):.*$', '', s)
    return s.strip()
def census(fn):
    out = collections.defaultdict(list)
    stack = []          # (indent, label)
    lines = [l.rstrip('\n') for l in open(fn, errors='replace')]
    for l in lines:
        s = l.lstrip(' ')
        ind = len(l) - len(s)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        if s.startswith('\\_'):
            m = re.match(r'\\_([A-Za-z_0-9]+): (\(([^)]*)\))?', s)
            lab = (m.group(1) + ':' + (m.group(3) or '')) if m else clean(s)
            stack.append((ind, lab))
        elif s.startswith('|'):
            m = re.match(r'\|(vpi[A-Za-z_0-9]+):', s)
            lab = m.group(1) if m else clean(s)
            stack.append((ind, lab))
    # second pass: record actual bindings
    stack = []
    for i, l in enumerate(lines):
        s = l.lstrip(' ')
        ind = len(l) - len(s)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        lab = None
        if s.startswith('\\_'):
            m = re.match(r'\\_([A-Za-z_0-9]+): (\(([^)]*)\))?', s)
            lab = (m.group(1) + ':' + (m.group(3) or '')) if m else clean(s)
        elif s.startswith('|'):
            m = re.match(r'\|(vpi[A-Za-z_0-9]+):', s)
            lab = m.group(1) if m else clean(s)
        if lab is None:
            continue
        if lab == 'vpiActual' and i + 1 < len(lines):
            nxt = lines[i+1].lstrip(' ')
            m = re.match(r'\\_([A-Za-z_0-9]+): (\(([^)]*)\))?', nxt)
            val = (m.group(1) + ':' + (m.group(3) or '')) if m else clean(nxt)
            key = '/'.join(x[1] for x in stack if not x[1].startswith('ref_typespec')
                           and not x[1].startswith('ref_obj'))
            out[key].append(val)
        stack.append((ind, lab))
    return {k: sorted(v) for k, v in out.items()}
if __name__ == '__main__':
    c = census(sys.argv[1])
    for k in sorted(c):
        print(k + '\t' + ','.join(c[k]))
