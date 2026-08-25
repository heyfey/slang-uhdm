#!/usr/bin/env python3
"""r10v150 cell scorer — JUDGE language.  Drops what no generated Compare
reads: VpiParent, VpiFullName (both the |vpiFullName: line AND the
parenthesised fullname the dump synthesises onto every header line), VpiFile,
and object ids.  Everything else (VpiType, VpiName, VpiDefName, line/col,
decompile, arguments, the reference targets) is kept."""
import re,sys,os
def load(fn, wd):
    if not os.path.exists(fn): return None
    t=open(fn,errors='replace').read().replace(wd,'@WD@')
    t=re.sub(r', id:\d+','',t)
    ls=t.split('\n'); out=[]; i=0
    while i<len(ls):
        s=ls[i].strip()
        if s=='|vpiParent:': i+=2; continue
        if s.startswith('|vpiFullName:'): i+=1; continue
        l=re.sub(r'^(\s*\\_[A-Za-z_0-9]+:) \([^)]*\)', r'\1', ls[i])
        l=re.sub(r'^(\s*\\_[A-Za-z_0-9]+: [^ ]+) \([^)]*\)', r'\1', l)
        l=re.sub(r'file:[^,]*,\s*','',l)
        out.append(l); i+=1
    return out
def cells(lines, pat):
    out={}
    if lines is None: return out
    for i,l in enumerate(lines):
        m=re.search(r'\\_(function|task):.*', l)
        if not m: continue
        # name comes from the following |vpiName: line at depth+1
        ind=len(l)-len(l.lstrip()); j=i+1; nm=None
        while j<len(lines):
            s=lines[j]
            if not s.strip(): j+=1; continue
            if len(s)-len(s.lstrip())<=ind: break
            if nm is None and s.strip().startswith('|vpiName:'): nm=s.strip()[9:]
            j+=1
        if nm is None or not re.fullmatch(pat, nm): continue
        if nm in out: continue
        out[nm]='\n'.join(x.strip() for x in lines[i:j])
    return out
def main():
    d=sys.argv[1]; pat=sys.argv[2]
    sfx='e' if os.environ.get('VIEW')=='elab' else ''
    g=load(os.path.join(d,'g%s.dump'%sfx),d); o=load(os.path.join(d,'o%s.dump'%sfx),d); q=load(os.path.join(d,'q%s.dump'%sfx),d)
    G,O,Q=cells(g,pat),cells(o,pat),cells(q,pat)
    tally={}
    for n in sorted(set(G)|set(O)|set(Q)):
        gg,oo,qq=G.get(n),O.get(n),Q.get(n)
        if gg is None: v='NOGOLDEN'
        elif oo==gg and qq==gg: v='RIGHT'
        elif oo!=gg and qq==gg: v='FIXED'
        elif oo==gg and qq!=gg: v='BROKEN'
        elif oo==qq: v='UNMOVED'
        else: v='MOVEDWRONG'
        tally[v]=tally.get(v,0)+1
        print('%-12s %s'%(v,n))
    print('-- '+os.path.basename(d)+' '+os.environ.get('VIEW','def')+' '+' '.join('%s=%d'%(k,tally[k]) for k in sorted(tally)))
main()
