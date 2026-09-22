#!/usr/bin/env python3
"""r11u94 net-decl-assign cell scorer — r11v91's `nda91v.py` scored PER FIELD.

`nda91v.py` scores a cell as a whole tuple, so a cell whose VALUE and CONST
TYPE reach golden while its SIZE stays on a FENCED residue counts as neither
TO nor AWAY and reads as if nothing happened.  The laws this pass lands write
two fields and leave the third alone by design (golden's size on this road is
the READER's width, r11u91's R4 and its own pass's ground), so the score has
to name the fields.

usage: nda94.py <golden.dump> <tagA.dump> <tagB.dump>
"""
import re
import sys

FIELDS = ('v', 'ct', 'sz', 'd')


def read(p):
    L = open(p, errors='replace').read().split('\n')
    res = {}
    for i, l in enumerate(L):
        if 'vpiNetDeclAssign:1' not in l:
            continue
        blk = '\n'.join(L[i:i + 40])
        m = re.search(r'\|vpiRhs:\s*\n\s*\\_constant:[^\n]*\n(.*?)'
                      r'\|vpiLhs:\s*\n\s*\\_logic_net: \(([^)]*)\)', blk, re.S)
        if not m:
            continue
        c = m.group(1)
        n = m.group(2).split('.')[-1]
        d = re.search(r'\|vpiDecompile:([^\n]*)', c)
        s = re.search(r'\|vpiSize:(\d+)', c)
        v = re.search(r'\|((?:INT|UINT|HEX|BIN|DEC|OCT|REAL|STRING):[^\n]*)', c)
        t = re.search(r'\|vpiConstType:(\d+)', c)
        res[n] = {'v': v.group(1) if v else '?',
                  'ct': t.group(1) if t else '?',
                  'sz': s.group(1) if s else '?',
                  'd': d.group(1) if d else '?'}
    return res


def main():
    g, a, b = (read(x) for x in sys.argv[1:4])
    tot = dict(TO=0, AWAY=0, STILL=0, EQ=0, MWRONG=0, MISSING=0)
    for n in sorted(g):
        G, A, B = g[n], a.get(n), b.get(n)
        if A is None or B is None:
            tot['MISSING'] += 1
            print(f'{n:8s} MISSING on one side')
            continue
        marks = []
        for f in FIELDS:
            if A[f] == G[f] and B[f] == G[f]:
                tot['EQ'] += 1
            elif A[f] != G[f] and B[f] == G[f]:
                tot['TO'] += 1
                marks.append('TO:' + f)
            elif A[f] == G[f] and B[f] != G[f]:
                tot['AWAY'] += 1
                marks.append('AWAY:' + f)
            elif A[f] != B[f]:
                tot['MWRONG'] += 1
                marks.append('MOVED-WRONG:' + f)
            else:
                tot['STILL'] += 1
                marks.append('still:' + f)
        print(f"{n:8s} G={' '.join(G[f] for f in FIELDS):34s} "
              f"P={' '.join(A[f] for f in FIELDS):34s} "
              f"L={' '.join(B[f] for f in FIELDS):34s} {' '.join(marks)}")
    print('PER-FIELD  ' + '  '.join(f'{k}={v}' for k, v in tot.items()))


main()
