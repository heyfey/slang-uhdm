#!/usr/bin/env python3
# score112.py <golden.dump> <ours.dump> — arm scorer for
# § classTdCloneSpecOverridesOwnArgs112.
# For every type_parameter, the SET of actual typespec names its
# |vpiTypespec ref_typespec reaches, keyed by the type_parameter's own
# fullname.  SPAN-FREE (spans are not read by any generated Compare) and
# ORDER-BLIND (a set per key), so a byte-order flip cannot score.
import sys, re, collections
NAME = re.compile(r'\\_(\w+): \(([^)]*)\)')
def indent(l): return len(l) - len(l.lstrip())
def block(lines, i):
    b = indent(lines[i]); j = i+1; out=[]
    while j < len(lines):
        l = lines[j]
        if not l.strip() or indent(l) <= b: break
        out.append(j); j += 1
    return out
def cen(path):
    lines = open(path, errors='replace').read().split('\n')
    out = collections.defaultdict(set)
    for i, l in enumerate(lines):
        m = NAME.search(l)
        if not m or m.group(1) != 'type_parameter': continue
        d = indent(l); full = m.group(2)
        for q in block(lines, i):
            if lines[q].strip() == '|vpiTypespec:' and indent(lines[q]) == d+2:
                rt = q+1; rd = indent(lines[rt])
                for r in block(lines, rt):
                    if lines[r].strip() == '|vpiActual:' and indent(lines[r]) == rd+2:
                        mm = NAME.search(lines[r+1])
                        if mm: out[full].add((mm.group(1), mm.group(2)))
                        break
                break
    return out
a, b = cen(sys.argv[1]), cen(sys.argv[2])
same=diff=oa=ob=0
for k in sorted(set(a)|set(b)):
    va, vb = a.get(k), b.get(k)
    if va is None: ob+=1;  print('ONLY-OURS   %s :: %s' % (k, sorted(vb)))
    elif vb is None: oa+=1; print('ONLY-GOLDEN %s :: %s' % (k, sorted(va)))
    elif va == vb: same+=1
    else:
        diff+=1
        print('DIFF %s\n     GOLDEN=%s\n     OURS  =%s' % (k, sorted(va), sorted(vb)))
print('--- keys=%d same=%d DIFF=%d only-golden=%d only-ours=%d'
      % (len(set(a)|set(b)), same, diff, oa, ob))
