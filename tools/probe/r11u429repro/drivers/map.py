import os,sys
fence=[l.strip() for l in open('/tmp/r11u429_scratch/fence.txt') if l.strip()]
SR='/home/heyfey/git-repos/slang-uhdm/third_party/Surelog'
tops=[SR+'/tests', SR+'/third_party/tests']
names={'surelog':set(),'u2r':set(),'probe':set()}
for line in open('/tmp/r11u429_scan/cands.txt'):
    law,t,d=line.split()
    if t=='surelog':
        x=d
        while x and not any(x==tp for tp in tops):
            sl=[f[:-3] for f in os.listdir(x) if f.endswith('.sl')]
            if sl:
                for n in sl: names['surelog'].add(n)
                break
            x=os.path.dirname(x)
    elif t=='u2r':
        names['u2r'].add(d.split('/test/')[1].split('/')[0])
    else:
        names['probe'].add(d.split('/tests/probe/')[1])
for k in names:
    v=sorted(n for n in names[k] if not any(f in n for f in fence))
    open('/tmp/r11u429_scan/%s.names'%k,'w').write('\n'.join(v)+'\n')
    print(k,len(v))
