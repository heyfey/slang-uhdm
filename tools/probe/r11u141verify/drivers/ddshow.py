import sys, os, collections, re, subprocess
wd,P,L=sys.argv[1:4]; key=os.path.basename(wd.rstrip('/'))
def c(f): return collections.Counter(re.sub(r'/\S+/','/',l.strip()) for l in open(f+'.dump').read().splitlines() if l.strip() and '.uhdm:' not in l)
g=c(f'/tmp/r11u141_gc/{key}.uhdm'); p=c(f'{wd}/{P}.uhdm'); l=c(f'{wd}/{L}.uhdm')
print('fixed:',list((p-g-(l-g)).elements())[:8]); print('new  :',list((l-g-(p-g)).elements())[:8])
g2=[x for x in (g-p).elements()][:8]; print('golden lines P lacks:',g2)
