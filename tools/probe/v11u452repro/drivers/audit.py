import os,re,sys
src=open('/tmp/wt_v11u452/tools/probe/r11u107repro/canaudit.sh').read()
m=re.search(r'^FENCED=(.*)$',src,re.M)
names=[x for x in re.split(r'[\s"\'|()]+',m.group(1)) if x and x not in ('',)]
open('/tmp/v11u452_scr/fenced.lst','w').write('\n'.join(names)+'\n')
W,B=sys.argv[1],sys.argv[2]
for corpus in ('surelog','uhdm2rtlil','svtests'):
    paths=[]
    for r,ds,fs in os.walk(os.path.join(W,corpus)):
        if 'cmds.txt' in fs: paths.append(os.path.join(r,'cmds.txt'))
    paths=[p for p in paths if not any(n in p for n in names)]
    n=len(paths); hit=0; other=0
    for p in paths:
        t=open(p,errors='replace').read()
        if B in t: hit+=1
        elif 'slang' in t.split('\n')[0] or re.search(r'^slang', t, re.M): other+=1
    print(corpus, 'records', n, 'naming_binary', hit, 'other_slang_records', other)
