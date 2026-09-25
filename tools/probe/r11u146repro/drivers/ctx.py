import sys,subprocess,glob,re,os
# ctx.py <workdir> <corpus> <mode> <name> [max]: print the first diffs with their ancestor type chain
wd,corpus,mode,name=sys.argv[1:5]; mx=sys.argv[5] if len(sys.argv)>5 else '3'
F=set(os.environ.get('FENCED','').split())
assert len(F)==4 and name not in F
d=glob.glob(f'{wd}/{corpus}/{mode}/{name}-*')[0]
g=re.search(r'goldens/([0-9a-f]+)',open(d+'/cmds.txt').read()).group(1)
gu=f'/home/heyfey/.cache/slang-uhdm-goldens/{g}/golden.uhdm'
out=subprocess.run(['/tmp/r11u146_bin/uhdm-strictcmp','--max',mx,'--dump-a','/tmp/r11u146_ctxA.txt','--dump-b','/tmp/r11u146_ctxB.txt',gu,d+'/slang.uhdm'],capture_output=True,text=True).stdout
A=[l.rstrip('\n').split('\t') for l in open('/tmp/r11u146_ctxA.txt')]
B=[l.rstrip('\n').split('\t') for l in open('/tmp/r11u146_ctxB.txt')]
for m in re.finditer(r'#(\d+) (\w+)',out):
    i=int(m.group(1)); 
    for tag,R in (('A',A),('B',B)):
        if i>=len(R): continue
        dep=int(R[i][0]); chain=[]; j=i
        while j>=0 and dep>1:
            j-=1
            if int(R[j][0])<dep: dep=int(R[j][0]); chain.append(R[j][1]+('('+R[j][2]+')' if R[j][2] else ''))
        print(f'#{i} {m.group(2)} {tag}: {"|".join(R[i][1:12])}  <- {" < ".join(chain[:7])}')
