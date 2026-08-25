import os,re,sys
roots=['/home/heyfey/git-repos/Surelog/tests','/home/heyfey/git-repos/Surelog/third_party/tests',
 '/home/heyfey/git-repos/Surelog/third_party/UVM','/home/heyfey/git-repos/uhdm2rtlil/test']
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
        else: out.append(c); i+=1
    return ''.join(out)
close=re.compile(r'\)\s*\.\s*[A-Za-z_]')
ident=re.compile(r'[A-Za-z_0-9$#:\]\[]')
kw={'if','while','for','foreach','case','casex','casez','repeat','return','always','initial','assert','assume','cover','wait','do','with','posedge','negedge','and','or','not','begin','end','func','import','new'}
cnt={}
for root in roots:
    for dp,dn,fn in os.walk(root):
        for f in fn:
            if not f.endswith(exts): continue
            p=os.path.join(dp,f)
            try: txt=open(p,errors='replace').read()
            except Exception: continue
            s=strip(txt)
            for m in close.finditer(s):
                # find matching '('
                i=m.start(); d=0
                while i>=0:
                    if s[i]==')': d+=1
                    elif s[i]=='(':
                        d-=1
                        if d==0: break
                    i-=1
                if i<0: continue
                j=i-1
                while j>=0 and s[j] in ' \t\n': j-=1
                k=j
                while k>=0 and ident.match(s[k]): k-=1
                head=s[k+1:j+1].strip()
                if not head or head in kw: cls='PARENEXPR/kw:'+head
                elif '::' in head: cls='SCOPED'
                elif head.startswith('$'): cls='SYSCALL'
                else: cls='BARE'
                ln=s[:i].count('\n')+1
                cnt.setdefault(cls,[]).append('%s:%d %s'%(p,ln,txt.split('\n')[ln-1].strip()[:110]))
for c in sorted(cnt):
    print('===',c,len(cnt[c]))
    for x in sorted(set(cnt[c]))[:25]: print('   ',x)
