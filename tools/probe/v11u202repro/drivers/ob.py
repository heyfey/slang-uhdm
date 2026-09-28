#!/usr/bin/env python3
# v11u202: order-blind DUMP census (uhdm-dump lines, ids and paths stripped, leading spaces kept? no: stripped) of one case
# usage: ob.py <golden.dump> <pris.dump> <x.dump> [v]   prints dist pris->x and LOST (golden&pris - x) / GAINED
import sys, re, collections
def ld(f):
    c=collections.Counter()
    for l in open(f):
        if 'Restored design' in l: continue
        l=re.sub(r', id:\d+','',l); l=re.sub(r'file:[^,]*/','file:',l); c[l.strip()]+=1
    return c
G,P,X=(ld(f) for f in sys.argv[1:4])
lost=(G&P)-X; gained=(G&X)-P
print(f'obdist {sum((P-G).values())} -> {sum((X-G).values())} lost={sum(lost.values())} gained={sum(gained.values())}')
if len(sys.argv)>4:
    for k,v in lost.items(): print('  LOST',v,k)
    for k,v in list(gained.items())[:15]: print('  GAIN',v,k)
