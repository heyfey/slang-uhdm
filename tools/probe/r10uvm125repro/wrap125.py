#!/usr/bin/env python3
"""r10uvm125 — the WRAPPER census, keyed on the CALL ITSELF (kind|name|span)
plus the argument INDEX, so it joins across the two producers without depending
on either one's parent chain (which carries producer-specific block spans).

Per cell the payload is only what this law is about:
    PLAIN:<arg kind>            a bare argument object
    OP82x1:<inner kind>         a ONE-OPERAND operation(vpiAssignmentOp=82)
    OP<n>x<k>:<inner kind>      any other operation argument
plus, for OP82x1 cells, the inner operand's PARENT KIND as its own column.

LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the official uhdm-cmp is the judge.
  usage: wrap125.py <g.cen> <ours.cen> [label]
"""
import sys, collections, re

def pay(p):
    f = p.split('|')
    kind = re.sub(r'\(.*\)$', '', f[0])
    if kind != 'operation':
        return 'PLAIN:' + kind, '-'
    m = re.match(r'op(\d+)', f[1]); n = m.group(1) if m else '?'
    k = re.search(r'nops=(\d+)', f[1]); k = k.group(1) if k else '?'
    inner = ip = '-'
    for x in f[2:]:
        if x.startswith('inner='):
            inner = re.sub(r'\(.*\)$', '', x[6:])
        if x.startswith('innerparent='):
            ip = x[12:].split('@')[0]
    return 'OP%sx%s:%s' % (n, k, inner), ip

def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        if not ln.startswith('CELL\t'):
            continue
        f = ln.rstrip('\n').split('\t')
        call, idx, payload = f[2], f[3], f[4]
        dirn = f[5] if len(f) > 5 else 'dir=-'
        v, ip = pay(payload)
        d[(call, idx)][(v, ip, dirn)] += 1
    return d

g = load(sys.argv[1]); o = load(sys.argv[2])
lab = sys.argv[3] if len(sys.argv) > 3 else ''
same = wrong = og = oo = 0
byshape = collections.Counter()
for k in set(g) | set(o):
    gv, ov = g.get(k, collections.Counter()), o.get(k, collections.Counter())
    inter = gv & ov
    same += sum(inter.values())
    gr, orr = gv - inter, ov - inter
    gl = sorted(gr.elements()); ol = sorted(orr.elements())
    n = min(len(gl), len(ol))
    wrong += n
    og += len(gl) - n; oo += len(ol) - n
    for i in range(n):
        byshape[(gl[i][0], ol[i][0], ol[i][1], gl[i][2])] += 1
    for x in gl[n:]:
        byshape[(x[0], '<absent>', '-', x[2])] += 1
    for x in ol[n:]:
        byshape[('<absent>', x[0], x[1], x[2])] += 1
print("%-22s SAME=%d MOVED-WRONG=%d ONLY-GOLDEN=%d ONLY-OURS=%d" %
      (lab, same, wrong, og, oo))
for (gs, os_, ip, dirn), c in sorted(byshape.items(), key=lambda t: -t[1]):
    print("    %6d  GOLD=%-28s OURS=%-28s innerparent=%-12s %s" %
          (c, gs, os_, ip, dirn))
