# r11u19 SHAPE LISTER: every cont_assign in the JUDGE-REACHABLE ELABORATED
# listing, keyed by (owner kind, Lhs name, line:col), with the Rhs OBJECT KIND
# and, for a constant, its size / value / decompile / constType.
import re, sys

def shapes(path):
    L = open(path).read().split('\n')
    # section: from |uhdmtopModules: to the weaklyReferenced tail
    try:
        n = next(i for i, l in enumerate(L) if l.startswith('|uhdmtopModules:'))
    except StopIteration:
        n = 0
    L = L[n:]
    w = next((i for i, l in enumerate(L) if l.startswith('\\_weaklyReferenced:')), len(L))
    L = L[:w]
    out = {}
    for i, ln in enumerate(L):
        m = re.search(r'\\_cont_assign: , line:(\d+):(\d+)', ln)
        if not m:
            continue
        if i and L[i-1].strip() in ('|vpiParent:', '|vpiCont_assign:'):
            continue
        ind = len(ln) - len(ln.lstrip())
        loc = m.group(1) + ':' + m.group(2)
        owner, lhs, rhs = '?', '?', '?'
        j = i + 1
        while j < len(L):
            s = L[j]
            k = len(s) - len(s.lstrip())
            if k <= ind:
                break
            t = s.strip()
            if t == '|vpiParent:' and owner == '?':
                owner = re.sub(r', id:\d+', '', L[j+1].strip()).split(',')[0]
            if t == '|vpiLhs:':
                a = L[j+1].strip()
                lhs = re.sub(r', id:\d+', '', a).split(',')[0]
            if t == '|vpiRhs:':
                a = L[j+1].strip()
                kind = a.split(':')[0].lstrip('\\_')
                rhs = kind
                ri = len(L[j+1]) - len(L[j+1].lstrip())
                ex = []
                q = j + 2
                while q < len(L):
                    s2 = L[q]
                    k2 = len(s2) - len(s2.lstrip())
                    if k2 <= ri:
                        break
                    t2 = s2.strip()
                    for f in ('|vpiSize:', '|vpiDecompile:', '|vpiConstType:',
                              '|vpiOpType:'):
                        if t2.startswith(f):
                            ex.append(t2)
                    if re.match(r'^\|(UINT|INT|BIN|HEX|OCT|DEC|STRING|SCAL|REAL):', t2):
                        ex.append(t2)
                    if k2 == ri + 2 and t2.startswith('\\_'):
                        ex.append('  op=' + re.sub(r', id:\d+', '', t2).split(':')[0].lstrip('\\_'))
                    q += 1
                if ex:
                    rhs += ' {' + ' '.join(ex) + '}'
            j += 1
        out.setdefault((owner, lhs, loc), []).append(rhs)
    return out

g = shapes(sys.argv[1]); o = shapes(sys.argv[2])
n = 0
for k in sorted(set(g) | set(o)):
    a, b = g.get(k), o.get(k)
    tag = 'SAME' if a == b else 'DIFF'
    if a != b:
        n += 1
    print(f"  [{tag}] {k[2]:>8} {k[0]} {k[1]}")
    print(f"        G={a}")
    if a != b:
        print(f"        O={b}")
print("DIFFERING CA SHAPES:", n, "of", len(set(g) | set(o)))
