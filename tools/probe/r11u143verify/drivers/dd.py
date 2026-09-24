#!/usr/bin/env python3
"""dd.py <casekeydir> <P> <L> : order-blind uhdm-dump delta vs golden (paths normalised).
P_dist / L_dist = symmetric multiset distance to golden (excess + missing lines); newexcess = lines L has beyond golden
that P did not; newmissing = golden lines L lacks that P had. NEWBAD when L_dist > P_dist."""
import sys, os, subprocess, collections, re
wd,P,L=sys.argv[1:4]; key=os.path.basename(wd.rstrip('/'))
D=os.environ.get('UHDM_DUMP','/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump')
def dump(f):
    c=f+'.dump'
    if not os.path.exists(c) or os.path.getmtime(c)<os.path.getmtime(f):
        o=subprocess.run([D,f],capture_output=True,text=True).stdout
        open(c,'w').write(o)
    ls=open(c).read().splitlines()
    return collections.Counter(re.sub(r'/\S+/','/',l.strip()) for l in ls if l.strip() and 'Restoring' not in l and '.uhdm:' not in l)
g=dump(f'/tmp/r11u143_gc/{key}.uhdm'); p=dump(f'{wd}/{P}.uhdm'); l=dump(f'{wd}/{L}.uhdm')
pd=sum(((p-g)+(g-p)).values()); ld=sum(((l-g)+(g-l)).values())
ne=(l-g)-(p-g); nm=(g-l)-(g-p)
print(f"{'NEWBAD' if ld>pd else 'OKDD'} P_dist={pd} L_dist={ld} newexcess={sum(ne.values())} newmissing={sum(nm.values())}", list(ne.elements())[:3], list(nm.elements())[:3])
