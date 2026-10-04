import sys,os,subprocess,collections,re
SC=os.path.join(os.environ['B'],'strictcmp_x'); assert os.access(SC,os.X_OK)
F=os.environ['FENCED'].split(); assert len(F)==4
def recs(u):
    assert not any(re.search(r'\b'+f+r'\b',u) for f in F)
    t=u+'.selfrec'
    subprocess.run([SC,'--max','0','--dump-a',t,'--dump-b','/dev/null',u,u],capture_output=True)
    c=collections.Counter(open(t).read().splitlines()); os.remove(t); return c
d=sys.argv[1]; a,b=sys.argv[2],sys.argv[3]
import glob
g=recs(glob.glob(d+'/gold_*/golden.uhdm')[0]); A=recs(f'{d}/{a}.uhdm'); B=recs(f'{d}/{b}.uhdm')
ga=g&A; gb=g&B
away=sum((ga-gb).values()); tow=sum((gb-ga).values())
print(d.split('/g/')[-1], f'{a}->{b}', 'away',away,'toward',tow)
