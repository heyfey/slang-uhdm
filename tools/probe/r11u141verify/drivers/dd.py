#!/usr/bin/env python3
"""dd.py <casekeydir> <P> <L> : order-blind uhdm-dump delta vs golden. newbad = dump lines L has off golden that P did not."""
import sys, os, subprocess, collections, re
wd,P,L=sys.argv[1:4]; key=os.path.basename(wd.rstrip('/'))
D=os.environ.get('UHDM_DUMP','/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump')
def dump(f):
    c=f+'.dump'
    if not os.path.exists(c):
        o=subprocess.run([D,f],capture_output=True,text=True).stdout
        open(c,'w').write(o)
    ls=open(c).read().splitlines()
    return collections.Counter(re.sub(r'/\S+/','/',l.strip()) for l in ls if l.strip() and 'Restoring' not in l and '.uhdm:' not in l)
g=dump(f'/tmp/r11u141_gc/{key}.uhdm'); p=dump(f'{wd}/{P}.uhdm'); l=dump(f'{wd}/{L}.uhdm')
bp=p-g; bl=l-g; newbad=bl-bp; fixed=bp-bl
print(f"{'NEWBAD' if newbad else 'OKDD'} P_off={sum(bp.values())} L_off={sum(bl.values())} newbad={sum(newbad.values())} fixed={sum(fixed.values())}", list(newbad.elements())[:4])
