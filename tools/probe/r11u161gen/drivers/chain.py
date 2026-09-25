#!/usr/bin/env python3
"""chain.py <prefix> [N]: for the first N differing records of <prefix>.strict (uhdm-strictcmp output), print
each record with its parent chain (ancestors by walk depth) from <prefix>.ra (golden) and <prefix>.rb (ours).
Only reads files the caller names; the caller's driver is fenced."""
import re, sys
p = sys.argv[1]; N = int(sys.argv[2]) if len(sys.argv) > 2 else 50
def load(f):
    try: return [l.rstrip('\n').split('\t') for l in open(f, errors='replace')]
    except FileNotFoundError: return []
A, B = load(p + '.ra'), load(p + '.rb')
def fmt(r):
    if not r or len(r) < 11: return str(r)
    d, t, n, dn, fn, fi, l, c, el, ec = r[:10]
    extra = ' '.join(x for x in r[10:] if x)
    return f"{t} '{n}'{' def='+dn if dn else ''}{' full='+fn if fn else ''} {fi}:{l}:{c}-{el}:{ec}{' ['+extra+']' if extra else ''}"
def chain(R, i, k=6):
    out = []; d = int(R[i][0])
    j = i - 1
    while j >= 0 and len(out) < k:
        if int(R[j][0]) < d:
            out.append(f"{R[j][1]} '{R[j][2]}' {R[j][6]}:{R[j][7]}"); d = int(R[j][0])
        j -= 1
    return ' < '.join(out)
n = 0
for l in open(p + '.strict'):
    m = re.match(r'#(\d+) (\S+)', l)
    if not m: continue
    i = int(m.group(1)); f = m.group(2); n += 1
    if n > N: break
    print(f"#{i} {f}")
    if i < len(A): print(f"  G: {fmt(A[i])}\n     < {chain(A, i)}")
    if i < len(B): print(f"  O: {fmt(B[i])}\n     < {chain(B, i)}")
