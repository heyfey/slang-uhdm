#!/usr/bin/env python3
"""r10uvm73 — DESIGN-WIDE VARIABLE CENSUS, span-keyed, ONE SIDE per run.

Reads a uhdm-dump text and reports, for every *_var / *_net object printed
anywhere in it, the merged set of KINDS it was printed with and whether the
print carried a direct |vpiTypespec: field.

KEY = (vpiFullName, line-span).  The span alone is NOT a key (a macro body's
line numbers travel with every expansion); the fullname carries package+class,
so fullname+span is unique in these designs — the script ASSERTS that by
reporting any key whose kinds disagree WITHIN one side (there are none here).

An object is printed several times (once per print-chain that reaches it); the
prints are merged, and a TYPESPEC-PRESENT reading wins over an absent one only
if some print showed one — divergence within a side is reported, never hidden.

usage: ct73cen.py <dump> [--kinds]              # emit key,kind,ts lines
       ct73cen.py <a.dump> <b.dump> --diff      # LHS=first(golden) vs RHS=second
"""
import re, sys, collections

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): (?:\(([^)]*)\))?(.*)$')
FIELD = re.compile(r'^(\s*)\|([A-Za-z_]+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')

def scan(path):
    """-> dict key -> {'kinds':set, 'ts':set(bool), 'n':int}"""
    out = collections.defaultdict(lambda: {'kinds': set(), 'ts': set(), 'n': 0})
    lines = open(path, errors='replace').read().split('\n')
    for i, ln in enumerate(lines):
        m = OBJ.match(ln)
        if not m:
            continue
        ind, kind, name, rest = m.group(1), m.group(2), m.group(3) or '', m.group(4)
        if not (kind.endswith('_var') or kind.endswith('_net')):
            continue
        sp = SPAN.search(rest)
        span = '%s:%s-%s:%s' % sp.groups() if sp else '?'
        # direct fields: indent == len(ind)+2 and start with '|', stop when
        # indentation returns to <= len(ind)
        ts = False
        j = i + 1
        want = len(ind) + 2
        while j < len(lines):
            f = FIELD.match(lines[j])
            o = OBJ.match(lines[j])
            cur = None
            if f:
                cur = len(f.group(1))
            elif o:
                cur = len(o.group(1))
            else:
                j += 1
                continue
            if cur <= len(ind):
                break
            if f and cur == want and f.group(2) == 'vpiTypespec':
                ts = True
            j += 1
        key = (name, span)
        e = out[key]
        e['kinds'].add(kind)
        e['ts'].add(ts)
        e['n'] += 1
    return out

def fmt(e):
    return '%s ts=%s' % ('|'.join(sorted(e['kinds'])),
                         '|'.join(str(int(x)) for x in sorted(e['ts'])))

if __name__ == '__main__':
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if '--diff' in sys.argv:
        A, B = scan(args[0]), scan(args[1])
        ka, kb = set(A), set(B)
        print('LHS(golden) objects=%d  RHS(ours) objects=%d' % (len(ka), len(kb)))
        print('LHS-only=%d RHS-only=%d shared=%d' %
              (len(ka - kb), len(kb - ka), len(ka & kb)))
        dis = []
        for k in sorted(ka & kb):
            a, b = A[k], B[k]
            if a['kinds'] != b['kinds'] or a['ts'] != b['ts']:
                dis.append((k, a, b))
        print('---- DISAGREEING SHARED KEYS: %d' % len(dis))
        tally = collections.Counter()
        for k, a, b in dis:
            tally[(fmt(a), fmt(b))] += 1
        for (x, y), n in tally.most_common():
            print('  %5d  LHS %-40s  RHS %s' % (n, x, y))
        print('---- cells:')
        for k, a, b in dis:
            print('  %-60s %-14s LHS %-32s RHS %s' % (k[0][:60], k[1], fmt(a), fmt(b)))
        for tag, only, src in (('LHS-only', ka - kb, A), ('RHS-only', kb - ka, B)):
            if only:
                print('---- %s (%d):' % (tag, len(only)))
                for k in sorted(only)[:40]:
                    print('  %-60s %-14s %s' % (k[0][:60], k[1], fmt(src[k])))
    else:
        S = scan(args[0])
        print('objects=%d' % len(S))
        for k in sorted(S):
            print('%s\t%s\t%s' % (k[0], k[1], fmt(S[k])))
