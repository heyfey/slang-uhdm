import sys,re,glob,subprocess,collections
exec(open('/tmp/v11u145_s/reccheck.py').read().split('out=[]')[0])
DUMP='/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump'
def ob(o):
    t=subprocess.run([DUMP,o],capture_output=True,text=True).stdout.split('\n')[1:]
    return collections.Counter(re.sub(r'id:\d+','',x).replace('/tmp/v11u145_wdL','W').replace('/tmp/v11u145_wdP','W') for x in t)
def d(a,b): return sum(((a-b)+(b-a)).values())
for l in sys.argv[1:]:
    corpus,name,mode=l.split(':')
    g,oL=gold_row('/tmp/v11u145_wdL',corpus,mode,name); _,oP=gold_row('/tmp/v11u145_wdP',corpus,mode,name)
    G=ob(g); P=ob(oP); L=ob(oL)
    # lines the law changed: removed from P (P-L) and added (L-P); how many of each exist in golden
    rem=P-L; add=L-P
    add_in_g=sum(min(c,G[k]) for k,c in add.items()); rem_in_g=sum(min(c,G[k]) for k,c in rem.items())
    print(f"{corpus} {name} {mode}: dist(G,P)={d(G,P)} dist(G,L)={d(G,L)} law_removed={sum(rem.values())}(of which in golden {rem_in_g}) law_added={sum(add.values())}(of which in golden {add_in_g})",flush=True)
