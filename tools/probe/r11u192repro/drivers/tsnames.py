#!/usr/bin/env python3
# tsnames.py <golden records> <ours records> [type]: side by side, every ref_typespec under a constant (walk records from uhdm-strictcmp --dump-a/-b), with its section (DEF = allModules, ELAB = topModules) and the constant span; ** marks a differing full name
import sys
def load(f):
    R=[l.rstrip('\n').split('\t') for l in open(f)]
    return R
A=load(sys.argv[1]); B=load(sys.argv[2]); ty=sys.argv[3] if len(sys.argv)>3 else 'ref_typespec'
def sect(R):
    out=[]; sec=''; stack={}
    for i,r in enumerate(R):
        d=int(r[0]) if r[0].isdigit() else -1
        stack[d]=r
        if d==1: sec=('DEF ' if r[2]=='' else 'ELAB ')+r[1]+':'+r[3]
        if r[1]==ty and d-1 in stack and stack[d-1][1]=='constant':
            c=stack[d-1]
            out.append((i+1,sec,c[6]+':'+c[7]+'-'+c[8]+':'+c[9],c[10],r[4],r[5]))
    return out
a=sect(A); b=sect(B)
for x,y in zip(a,b):
    flag='  ' if x[4]==y[4] else '**'
    print(flag, x[0], x[1][:28], x[2], x[3], 'G:',x[4], '| O:', y[4], y[5])
if len(a)!=len(b): print('COUNT', len(a), len(b))
