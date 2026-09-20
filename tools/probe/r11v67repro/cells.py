#!/usr/bin/env python3
import sys, subprocess, collections
HERE='/tmp/v11u67_scratch'
def rd(p):
    out = subprocess.run(['python3',HERE+'/nettype65.py',p],capture_output=True,text=True).stdout
    m = collections.defaultdict(list)
    for l in out.split('\n'):
        if not l: continue
        k,nt = l.rsplit('|NT=',1)
        m[k].append(int(nt))
    return {k:sorted(v) for k,v in m.items()}
d=sys.argv[1]; tags=sys.argv[2:]
sides=[('gold',rd(d+'/gold.%s.dump'%tags[0]))]
for t in tags: sides.append((t,rd(d+'/ours.%s.dump'%t)))
keys=sorted(set().union(*[set(s[1]) for s in sides]))
for k in keys:
    vals=[s[1].get(k) for s in sides]
    flag=''
    g=vals[0]
    if len(vals)>2:
        p,w=vals[1],vals[2]
        if p!=w: flag=' <<< TO-GOLDEN' if w==g else (' <<< *** AWAY' if p==g else ' <<< *** MOVED-WRONG')
    elif g!=vals[1]: flag=' <<< diff'
    print('%-64s %s%s' % (k, ' | '.join('%s=%s'%(s[0],v) for s,v in zip(sides,vals)), flag))
