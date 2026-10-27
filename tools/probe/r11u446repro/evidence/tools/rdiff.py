import sys,difflib
def load(f):
    out=[];stack=[]
    for l in open(f):
        x=l.rstrip('\n').split('\t')
        if not x[0].isdigit() or len(x)<14: continue
        d=int(x[0]); stack=stack[:d]; stack.append(x[1]+':'+x[2])
        out.append((l.rstrip('\n'),'/'.join(stack[1:-1])))
    return out
a=load(sys.argv[1]); b=load(sys.argv[2])
sm=difflib.SequenceMatcher(None,[x[0] for x in a],[x[0] for x in b],autojunk=False)
n=0
for tag,i1,i2,j1,j2 in sm.get_opcodes():
    if tag=='equal': continue
    print(tag)
    for x in a[i1:i2][:6]: print('  G',x[1][-90:],'|',' '.join(x[0].split('\t')[1:3]),x[0].split('\t')[5:8],x[0].split('\t')[13])
    for x in b[j1:j2][:6]: print('  O',x[1][-90:],'|',' '.join(x[0].split('\t')[1:3]),x[0].split('\t')[5:8],x[0].split('\t')[13])
    n+=1
    if n>int(sys.argv[3] if len(sys.argv)>3 else 30): break
