#!/usr/bin/env python3
# v11u282 fixsum.py <grid law.txt> <grid fix.txt>: per case-view pristine / law / fix / fix+R11U282_OFF / fix+R11V282_OFF
# (gridall.sh outputs, the fix grid run with the extra switch R11V282_OFF): movers, entering and leaving STRICT_EQUAL,
# the two switch identities, and every case-view where the fix and the law write different bytes (FIXDIFF).
import sys,re,collections
def load(f,ren={}):
    d=collections.defaultdict(dict)
    for l in open(f):
        p=l.split(None,3); lab=ren.get(p[2],p[2]); d[(p[0],p[1])][lab]=p[3].strip()
    return d
g=load(sys.argv[1]); fx=load(sys.argv[2],{'law':'fix','law+R11U282_OFF':'fix+U_OFF','law+R11V282_OFF':'fix+V_OFF'})
def md5(s): return re.search(r'md5=(\S+)',s).group(1)
def eq(s): return 'STRICT_EQUAL' in s
def ver(s): return re.sub(r' md5=\S+','',s)
n=0; c=collections.Counter()
for k in sorted(g):
    P=g[k]['pristine']; L=g[k]['law']; F=fx[k]['fix']; UO=fx[k]['fix+U_OFF']; VO=fx[k]['fix+V_OFF']; n+=1
    c['UOFF==P']+=md5(UO)==md5(P); c['VOFF==L']+=md5(VO)==md5(L)
    if md5(F)!=md5(P): c['fix_movers']+=1; c['fix_enter']+= (eq(F) and not eq(P)); c['fix_leave']+=(eq(P) and not eq(F))
    if md5(L)!=md5(P): c['law_movers']+=1; c['law_enter']+= (eq(L) and not eq(P)); c['law_leave']+=(eq(P) and not eq(L))
    if re.search(r'rc=(\S+)',F).group(1)!=re.search(r'rc=(\S+)',P).group(1): c['fix_rc_change']+=1
    if re.search(r'cmp=(\S+)',F).group(1)!=re.search(r'cmp=(\S+)',P).group(1): c['fix_cmp_change']+=1
    if md5(F)!=md5(L):
        c['fix_vs_law']+=1; print('FIXDIFF',k[0],k[1],'| law:',ver(L),'| fix:',ver(F))
print('case-views',n,dict(c))
