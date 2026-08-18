#!/usr/bin/env python3
# r10uvm93: extract every streaming operation (vpiOpType 71/72) from a uhdm-dump
# and report its location + the shape of its FIRST operand (the slice size).
import sys, re
lines = open(sys.argv[1]).read().split('\n')
def ind(l):
    return len(l) - len(l.lstrip(' '))
# find node-start lines "\_kind: ..." and attribute lines "|attr:val"
out = []
for i, l in enumerate(lines):
    m = re.match(r'^(\s*)\|vpiOpType:(71|72)$', l)
    if not m: continue
    base = len(m.group(1))
    # node header is the nearest preceding line at indent base-2 starting with \_
    j = i - 1
    hdr = None
    while j >= 0:
        if lines[j].lstrip().startswith('\\_') and ind(lines[j]) == base - 2:
            hdr = lines[j].strip(); break
        j -= 1
    # collect operands at this level: lines "|vpiOperand:" at indent base
    ops = []
    k = i + 1
    while k < len(lines):
        li = lines[k]
        if li.strip() == '' :
            k += 1; continue
        if ind(li) < base: break
        if ind(li) == base and li.strip() == '|vpiOperand:':
            # the operand node is the next line
            node = lines[k+1].strip()
            # gather its attribute lines (indent base+2, starting with |) until dedent
            attrs = []
            t = k + 2
            while t < len(lines) and (ind(lines[t]) > base + 1 or lines[t].strip()==''):
                s = lines[t].strip()
                if ind(lines[t]) == base + 2 and s.startswith('|') and not s.endswith(':'):
                    attrs.append(s)
                t += 1
            ops.append((node, attrs))
            k = t; continue
        k += 1
    first = ops[0] if ops else ('<none>', [])
    out.append((hdr, m.group(2), first))
for hdr, ot, (node, attrs) in out:
    print(f"OP{ot} {hdr}")
    print(f"    op0: {node}   [{' '.join(attrs)}]")
