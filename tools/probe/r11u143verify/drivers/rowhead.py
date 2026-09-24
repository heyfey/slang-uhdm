#!/usr/bin/env python3
"""rowhead.py <golden.uhdm> <ours.uhdm> [n]: the first n strict differences, each with its golden ancestor chain
(records: depth type name defname fullname file line col endline endcol ...)."""
import sys, subprocess, tempfile, os
g,o=sys.argv[1:3]; n=int(sys.argv[3]) if len(sys.argv)>3 else 2
t=tempfile.mkdtemp(prefix='r11u143_rh',dir='/tmp')
r=subprocess.run(['/tmp/r11u143_bin/strictx','--max','0','--diffs',t+'/d','--dump-a',t+'/a','--dump-b',t+'/b',g,o],capture_output=True,text=True)
print((r.stdout+r.stderr).strip().splitlines()[-1])
N=['depth','type','name','defname','fullname','file','line','col','endline','endcol','decompile','size','value','consttype']
if not os.path.exists(t+'/d'): sys.exit()
A=[l.split('\t') for l in open(t+'/a').read().split('\n')[:-1]]; B=[l.split('\t') for l in open(t+'/b').read().split('\n')[:-1]]
D=sorted(tuple(map(int,l.split())) for l in open(t+'/d') if l.strip())
seen=set()
for i,k in D:
    if i in seen: continue
    seen.add(i)
    if len(seen)>n: break
    chain=[];dep=int(A[i][0])
    for j in range(i-1,-1,-1):
        if int(A[j][0])<dep: chain.append(A[j]); dep=int(A[j][0])
        if dep==0: break
    print(f'#{i} {N[k]}: golden={A[i][k]!r} ours={B[i][k]!r}')
    print('   golden rec:', ' | '.join(A[i][:10])); print('   ours   rec:', ' | '.join(B[i][:10]))
    for c in chain[:5]: print('   under:', ' | '.join(c[:10]))
subprocess.run(['rm','-rf',t])
