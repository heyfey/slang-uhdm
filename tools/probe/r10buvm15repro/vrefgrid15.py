#!/usr/bin/env python3
# vbuvm15 verifier instrument: 3-way ref_obj -> vpiActual table from uhdm-dump
# text.  Sees EVERY ref_obj, including ones nested inside operations, concats
# and nested call arguments -- the blind spot of r10buvm15cen (which only reads
# a tf_call's DIRECT ref_obj arguments).
# key = <line>:<col>|<vpiName>   value = multiset of actual kind(name) or BARE
import re, sys, collections

REF = re.compile(r'^(\s*)\\_(\w+): \(([^)]*)\), line:(\d+):(\d+)')
ANY = re.compile(r'^(\s*)\\_(\w+)')
FLD = re.compile(r'^(\s*)\|(\w+):')

def parse(path):
    out = collections.Counter()
    lines = open(path, errors='replace').read().split('\n')
    for i, ln in enumerate(lines):
        m = REF.match(ln)
        if not m or m.group(2) != 'ref_obj':
            continue
        ind = len(m.group(1))
        lno, col = m.group(4), m.group(5)
        name = None
        actual = 'BARE'
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            if not l2.strip():
                j += 1; continue
            mi = re.match(r'^(\s*)[|\\]', l2)
            if not mi:
                break
            ind2 = len(mi.group(1))
            if ind2 <= ind:
                break
            if ind2 == ind + 2 and l2.lstrip().startswith('|vpiName:'):
                name = l2.split(':', 1)[1].strip()
            if ind2 == ind + 2 and l2.lstrip().startswith('|vpiActual:'):
                k = j + 1
                while k < len(lines) and not lines[k].strip():
                    k += 1
                ma = ANY.match(lines[k])
                if ma:
                    nm = re.search(r'\((.*?)\)', lines[k])
                    actual = ma.group(2) + '(' + (nm.group(1) if nm else '') + ')'
            j += 1
        out[(int(lno), int(col), name or '?')] += 0
        out[(int(lno), int(col), name or '?', actual)] += 1
    return out

def flat(c):
    d = collections.defaultdict(collections.Counter)
    for k, v in c.items():
        if len(k) == 4 and v:
            d[(k[0], k[1], k[2])][k[3]] += v
    return {k: ' '.join(f'{a}x{n}' for a, n in sorted(v.items())) for k, v in d.items()}

g = flat(parse(sys.argv[1]))
p = flat(parse(sys.argv[2]))
q = flat(parse(sys.argv[3]))
keys = sorted(set(g) | set(p) | set(q))
cnt = collections.Counter()
for k in keys:
    G, P, Q = g.get(k, '<absent>'), p.get(k, '<absent>'), q.get(k, '<absent>')
    if G == P == Q:
        v = 'same'
    elif G != P and G == Q:
        v = 'CONVERTED'
    elif G == P and G != Q:
        v = 'OVER-FIRE'
    elif G != P and G != Q and P != Q:
        v = 'MOVED-STILL-WRONG'
    else:
        v = 'residue'
    cnt[v] += 1
    if v != 'same' or len(sys.argv) > 4:
        print(f'{v:<18} {k[0]}:{k[1]} {k[2]}\n   G={G}\n   P={P}\n   Q={Q}')
print('-- ' + ' '.join(f'{k}={v}' for k, v in sorted(cnt.items())))
