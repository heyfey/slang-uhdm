import os,re,sys
roots=[
 '/home/heyfey/git-repos/Surelog/tests',
 '/home/heyfey/git-repos/Surelog/third_party/tests',
 '/home/heyfey/git-repos/Surelog/third_party/UVM',
 '/home/heyfey/git-repos/uhdm2rtlil/test',
]
exts=('.sv','.svh','.v','.vh')
def strip(txt):
    out=[];i=0;n=len(txt)
    while i<n:
        c=txt[i]
        if c=='/' and i+1<n and txt[i+1]=='/':
            while i<n and txt[i]!='\n': out.append(' '); i+=1
        elif c=='/' and i+1<n and txt[i+1]=='*':
            while i<n and not (txt[i]=='*' and i+1<n and txt[i+1]=='/'):
                out.append('\n' if txt[i]=='\n' else ' '); i+=1
            out.append('  '); i+=2
        elif c=='"':
            out.append(' '); i+=1
            while i<n and txt[i]!='"':
                if txt[i]=='\\': out.append(' '); i+=1
                if i<n: out.append('\n' if txt[i]=='\n' else ' '); i+=1
            out.append(' '); i+=1
        else:
            out.append(c); i+=1
    return ''.join(out)
pat=re.compile(r'([A-Za-z_]\w*)\s*(#\s*\()?')
scoped=re.compile(r'\b([A-Za-z_]\w*)\s*(#\s*\([^;]*?\)\s*)?::\s*([A-Za-z_]\w*)\s*\(')
hits=[]
for root in roots:
    for dp,dn,fn in os.walk(root):
        for f in fn:
            if not f.endswith(exts): continue
            p=os.path.join(dp,f)
            try: txt=open(p,errors='replace').read()
            except Exception: continue
            s=strip(txt)
            for m in scoped.finditer(s):
                # balance from the '(' at m.end()-1
                i=m.end()-1; d=0
                while i<len(s):
                    if s[i]=='(': d+=1
                    elif s[i]==')':
                        d-=1
                        if d==0: break
                    i+=1
                if i>=len(s): continue
                j=i+1
                while j<len(s) and s[j] in ' \t\n\r': j+=1
                if j<len(s) and s[j] in '.[':
                    ln=s[:m.start()].count('\n')+1
                    hits.append((p,ln,txt.split('\n')[ln-1].strip()[:150], s[j]))
for h in sorted(set(hits)):
    print('%s:%d [%s] %s'%(h[0],h[1],h[3],h[2]))
print('TOTAL',len(set(hits)))
