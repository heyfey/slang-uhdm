#!/usr/bin/env python3
"""dumpdelta.py <list.tsv: label golden oursP oursL> : order-blind uhdm-dump line multiset distance
to golden (lines of ours not in golden + lines of golden not in ours), pristine vs law."""
import sys, subprocess, re, collections, os
D=os.environ.get('UHDM_DUMP','/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump')
def dump(f):
    t=subprocess.run([D,f],capture_output=True,text=True).stdout.split('\n')[1:]
    t=[re.sub(r'file:[^ ,]*/','file:',re.sub(r'id:\d+','',l)).strip() for l in t]
    return collections.Counter(t)
for l in open(sys.argv[1]):
    lab,g,p,q=l.rstrip('\n').split('\t')[:4]
    G=dump(g); P=dump(p); L=dump(q)
    dp=sum(((P-G)+(G-P)).values()); dl=sum(((L-G)+(G-L)).values())
    newbad=sum(((L-G)-(P-G)).values()); fixed=sum(((P-G)-(L-G)).values())
    print(f'{"OK" if dl<=dp else "WORSE"}\t{lab}\tP={dp} L={dl} newbad={newbad} fixed={fixed}')
