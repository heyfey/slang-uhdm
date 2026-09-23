#!/usr/bin/env python3
# blk113.py <dump> <kind> <line:col> : print every `\_<kind>: ... line:<line:col>,` block of a
# uhdm-dump (the block = the header + its deeper-indented lines), path-normalised, as a
# multiset (count + block).  Blocks are keyed by content, so golden vs ours diff per cell.
import sys, re, collections
dump, kind, loc = sys.argv[1], sys.argv[2], sys.argv[3]
lines = open(dump, errors='replace').read().split('\n')
pat = re.compile(r'^(\s*)\\_' + re.escape(kind) + r': .*line:' + re.escape(loc) + r',')
out = collections.Counter()
for i, l in enumerate(lines):
    m = pat.match(l)
    if not m: continue
    ind = len(m.group(1)); blk = [l.strip()]
    for l2 in lines[i+1:]:
        ind2 = len(l2) - len(l2.lstrip())
        if not l2.strip() or ind2 <= ind: break
        blk.append(' ' * (ind2 - ind) + l2.strip())
    b = '\n'.join(blk)
    b = re.sub(r', id:\d+', '', b); b = re.sub(r'file:[^,]*,', '', b)
    out[b] += 1
for b, n in sorted(out.items()):
    print(f'[{n}x]'); print(b)
