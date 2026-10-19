import subprocess,sys,re,collections,os
DUMP='/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump'
def d(p):
    t=subprocess.run([DUMP,p],capture_output=True,text=True,timeout=1800).stdout
    t=re.sub(r'\bid:\d+','',t); t=re.sub(r'file:[^,\n]*/','file:',t)
    return collections.Counter(t.splitlines()[1:])
for row in sys.argv[1:]:
    P=f'/tmp/intr11u405/svtests/work/{row}/slang.uhdm'; L=f'/tmp/r11u407_wd/svtests/work/{row}/slang.uhdm'
    c=open(f'/tmp/r11u407_wd/svtests/work/{row}/cmds.txt').read()
    m=re.search(r'golden cache hit ([^)]*)\)',c); G=(m.group(1)+'/golden.uhdm') if m else f'/tmp/r11u407_wd/svtests/work/{row}/slpp_all/surelog.uhdm'
    g=d(G); p=d(P); l=d(L)
    dist=lambda x: sum(((g-x)+(x-g)).values())
    print(row,'pristine',dist(p),'law',dist(l))
