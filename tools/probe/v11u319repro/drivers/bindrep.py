#!/usr/bin/env python3
# v11u319 bindrep.py <rec>: from a uhdm-strictcmp --dump-a/--dump-b record file, every ref_obj with line:col, name and
# whether its actual is expanded right below it (first reached there: in these cases the parent DEFINITION's net).
import sys
L=[l.rstrip('\n').split('\t') for l in open(sys.argv[1])]
for i,r in enumerate(L):
    if len(r)>2 and r[1]=='ref_obj':
        d=int(r[0]); nx=L[i+1] if i+1<len(L) else None
        exp = nx is not None and int(nx[0])==d+1 and nx[1].endswith(('_net','_var'))
        print(f"{r[5]}:{r[6]}:{r[7]} {r[2]} {'DEFBIND:'+nx[4] if exp else '-'}")
