#!/usr/bin/env python3
# v11u301 fgridsum.py <fgrid out>: P/L/F/FV/FU transitions and the refinement switch restoring L on every F!=L view.
import collections,sys
r=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p=l.split(); d=dict(x.split('=',1) for x in p[3:] if '=' in x); d['st']=d.get('strict',p[3])
    r[p[1]][p[0]]=d
SW=['R11V301_CALLTOP_OFF','R11V301_CASTWQUAL_OFF','R11V301_XZLEAD_OFF']
c=collections.Counter(); out=[]
for cv in sorted(r):
    x=r[cv]; m=lambda k:x[k].get('md5')
    rcs={x[k].get('rc') for k in x}
    if rcs!={'0'}: c['rc_not0:'+','.join(sorted(map(str,rcs)))]+=1
    c['FU==P' if m('FU')==m('P') else 'FU!=P']+=1
    c['FV==L' if m('FV')==m('L') else 'FV!=L']+=1
    if m('P')!=m('L'): c['L moves']+=1
    if m('P')!=m('F'): c['F moves']+=1
    if 'STRICT_EQUAL' in x['P']['st'] and 'STRICT_EQUAL' not in x['F']['st']: c['F leaves SE']+=1; out.append('LEAVE '+cv)
    if 'STRICT_EQUAL' not in x['P']['st'] and 'STRICT_EQUAL' in x['F']['st']: c['F enters SE']+=1
    if 'STRICT_EQUAL' not in x['P']['st'] and 'STRICT_EQUAL' in x['L']['st']: c['L enters SE']+=1
    if m('F')!=m('L'):
        rest=[s for s in SW if m(s)==m('L')]
        c['F!=L']+=1; out.append('%s P=%s L=%s F=%s restoredL_by=%s F==P:%s'%(cv,x['P']['st'],x['L']['st'],x['F']['st'],rest,m('F')==m('P')))
for k,v in sorted(c.items()): print(k,v)
print('\n'.join(out))
