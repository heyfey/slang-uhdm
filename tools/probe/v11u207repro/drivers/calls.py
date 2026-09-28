#!/usr/bin/env python3
# print every func_call/task_call NAME at line with its argument summary, for g/p/l dumps of a run dir
import sys,subprocess,re,os
O=sys.argv[1]; name=sys.argv[2]
def calls(f):
    t=subprocess.run([os.environ['UHDM_DUMP'],f],capture_output=True,text=True).stdout.split('\n')
    out=[]
    for i,l in enumerate(t):
        m=re.match(r'^(\s*)\\_(func_call|task_call|method_func_call): \('+name+r'\), line:(\S+), endln:(\S+)',l)
        if not m: continue
        ind=len(m.group(1)); args=[]; fn=''
        j=i+1
        while j<len(t) and (len(t[j])-len(t[j].lstrip()))>ind:
            s=t[j].strip()
            if s=='|vpiArgument:':
                a=t[j+1].strip(); v=''
                k=j+2
                while k<len(t) and (len(t[k])-len(t[k].lstrip()))>(len(t[j+1])-len(t[j+1].lstrip())):
                    if re.match(r'\|(UINT|INT|STRING|REAL|BIN|HEX):',t[k].strip()): v=t[k].strip()
                    k+=1
                args.append(re.sub(r', id:\d+','',a)+v)
            if s in('|vpiFunction:','|vpiTask:'): fn=t[j+1].strip()
            j+=1
        out.append(f'{m.group(3)} [{fn}] '+' | '.join(args))
    return out
for tag in ('g','p','l'):
    print('==',tag)
    for c in sorted(set(calls(f'{O}/{tag}.uhdm'))): print('  ',c)
