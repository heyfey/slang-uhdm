#!/usr/bin/env python3
"""patref.py <records file> [...]: from uhdm-strictcmp --dump-a/--dump-b records (depth type name defname fullname
file line col endline endcol ...), list every param_assign whose Rhs is an operation carrying a ref_typespec as its
first child: `<owner #> <owner type> <owner name> | pa <line>:<col> | ref fullname=<fullname or EMPTY>`. An EMPTY
full name of that reference is an unparented reference (ComputeFullName over a null parent chain). No corpus data
is read by this script unless the caller passes it (the caller's fence applies)."""
import sys
for f in sys.argv[1:]:
    rows = [l.rstrip('\n').split('\t') for l in open(f)]
    stack = {}
    for i, r in enumerate(rows):
        d = int(r[0]); stack[d] = (i + 1, r)
        if r[1] == 'param_assign' and i + 2 < len(rows):
            o, t = rows[i + 1], rows[i + 2]
            if o[1] == 'operation' and int(o[0]) == d + 1 and t[1] == 'ref_typespec' and int(t[0]) == d + 2:
                own = stack.get(d - 1, (0, ['', '?', '', '']))
                print(f"{f.split('/')[-1]} #{own[0]} {own[1][1]} {own[1][2] or own[1][4]} | pa {r[6]}:{r[7]} | ref fullname={t[4] or 'EMPTY'}")
