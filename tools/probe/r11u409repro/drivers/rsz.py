import sys,subprocess,os,re,collections
D='/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump'
def ex(f,name):
    t=subprocess.run([D,f],capture_output=True,text=True).stdout.splitlines()
    sec='';out=collections.Counter()
    for i,l in enumerate(t):
        if l.startswith('|uhdm'): sec=l[1:].rstrip(':')
        if l.strip().startswith('\\_param_assign:'):
            ind=len(l)-len(l.lstrip())
            sz=v=lhs=None; j=i+1; inr=False
            while j<len(t) and (len(t[j])-len(t[j].lstrip())>ind or t[j].strip().startswith('|')) and not (len(t[j])-len(t[j].lstrip())<=ind and t[j].strip().startswith('\\_')):
                s=t[j].strip()
                if s=='|vpiRhs:': inr=True
                elif s=='|vpiLhs:': inr=False; lhs=t[j+1].strip()
                elif inr and s.startswith('|vpiSize:') and sz is None: sz=s
                elif inr and re.match(r'\|(UINT|INT|BIN|HEX|DEC|STRING):',s) and v is None: v=s
                j+=1
            if lhs and re.search(r'[.:]%s\)'%name,lhs): out[(sec,sz,v)]+=1
    return out
c=sys.argv[1]; G=sys.argv[2]; O=sys.argv[3]; n=sys.argv[4] if len(sys.argv)>4 else 'R'
g=ex(G,n); o=ex(O,n)
for k in sorted(set(g)|set(o), key=str):
    print(('  ' if g[k]==o[k] else '* '), k, 'G',g[k],'O',o[k])
