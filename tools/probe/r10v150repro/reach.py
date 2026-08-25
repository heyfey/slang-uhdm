#!/usr/bin/env python3
"""Independent reach scan: find every written `<expr>(...)` . <identifier>
where the `(` ... `)` is a balanced argument list immediately preceded by an
identifier or a `::`-qualified name.  Comments and string literals stripped
first.  Reports the ROOT KIND."""
import os,re,sys
roots=sys.argv[1:]
def strip(t):
    out=[];i=0;n=len(t)
    while i<n:
        c=t[i]
        if c=='/' and i+1<n and t[i+1]=='/':
            while i<n and t[i]!='\n': i+=1
        elif c=='/' and i+1<n and t[i+1]=='*':
            i+=2
            while i+1<n and not(t[i]=='*' and t[i+1]=='/'): i+=1
            i+=2
        elif c=='"':
            out.append(' '); i+=1
            while i<n and t[i]!='"':
                if t[i]=='\\': i+=1
                i+=1
            i+=1
        else:
            out.append(c); i+=1
    return ''.join(out)
ID=r'[A-Za-z_][A-Za-z_0-9$]*'
hits={}
for root in roots:
    for dp,dn,fn in os.walk(root):
        for f in fn:
            if not f.endswith(('.sv','.svh','.v','.vh')): continue
            p=os.path.join(dp,f)
            try: t=open(p,errors='replace').read()
            except Exception: continue
            if ').' not in t: continue
            s=strip(t)
            for m in re.finditer(r'\)\s*\.\s*('+ID+r')',s):
                # walk back to the matching '('
                i=m.start(); depth=0; j=i
                while j>=0:
                    if s[j]==')': depth+=1
                    elif s[j]=='(':
                        depth-=1
                        if depth==0: break
                    j-=1
                if j<0: continue
                # what precedes the '('?
                k=j-1
                while k>=0 and s[k] in ' \t\n': k-=1
                mm=re.search(r'('+ID+r'(\s*::\s*'+ID+r')*)$',s[:k+1])
                if not mm: continue
                pre=mm.group(1)
                if pre in ('if','while','for','case','casex','casez','repeat','foreach','return','assert','assume','cover','always','initial','wait','posedge','negedge','function','task','module','interface','program','begin','end','virtual','with','new','import','disable','forever'): continue
                kind = 'scoped' if '::' in pre else 'bare'
                line=s[:j].count('\n')+1
                hits.setdefault(kind,[]).append((p,line,pre+'(...).'+m.group(1)))
for k in sorted(hits):
    print('=== %s : %d'%(k,len(hits[k])))
    for p,l,txt in hits[k]:
        print('  %s:%d  %s'%(p,l,txt))
