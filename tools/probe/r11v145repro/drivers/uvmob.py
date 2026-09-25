import hashlib,subprocess,re,collections
DUMP='/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump'
V=['pristine','law','sw_OFF','DEFFILLIMP','UNSPARAMTS','PSBAREREF','UNARYOWN','LPBOUNDOWN','BASESELOP','IMPARITH']
def ob(p):
    t=subprocess.run([DUMP,p],capture_output=True,text=True).stdout.split('\n')[1:]
    return collections.Counter(re.sub(r'id:\d+','',x) for x in t)
def d(a,b): return sum(((a-b)+(b-a)).values())
for name,mode in [('MiniAmiq','default'),('MiniAmiq','testflags'),('Scoreboard','default'),('SeqDriver','default'),('SeqDriver','testflags'),('SimpleUVM','default'),('SimpleUVM','testflags'),('Earlgrey_0_1','default')]:
    k=hashlib.md5(f'surelog{name}{mode}'.encode()).hexdigest()[:10]
    D=[ob(f'/tmp/v11u145_s/att/{k}/v{i:02d}.uhdm') for i in range(10)]
    P,L=D[0],D[1]
    s=f'{name} {mode}: ob(pris,law)={d(P,L)} ob(pris,OFF)={d(P,D[2])}'
    for i in range(3,10):
        s+=f' {V[i]}:vsLaw={d(D[i],L)},vsPris={d(D[i],P)}'
    print(s,flush=True)
