#!/usr/bin/env python3
"""r10uvm150 cell scorer.  For each named function/task/class-method cell in an
arm, extract its DUMP SUBTREE from golden / pristine / patched and classify:
  RIGHT      o==g and q==g   (an arm AGREEING is not an arm TESTING; counted)
  FIXED      o!=g and q==g   -> TO-GOLDEN
  BROKEN     o==g and q!=g   -> AWAY-GOLDEN   (must be 0)
  UNMOVED    o!=g, q!=g, o==q -> still wrong, untouched
  MOVEDWRONG o!=g, q!=g, o!=q -> must be 0
Object ids and the arm's workdir path are normalised away; vpiFullName is NOT
read by the judge but IS kept here on purpose, so the scorer is STRICTER than
uhdm-cmp."""
import re,sys,os
def load(fn, wd):
    if not os.path.exists(fn): return None
    t=open(fn,errors='replace').read()
    t=t.replace(wd,'@WD@')
    t=re.sub(r', id:\d+','',t)
    ls=t.split('\n')
    if os.environ.get('JUDGE')=='1':
        # The judge reads no VpiParent (no generated Compare does) and no
        # VpiFullName.  Drop both so the scorer speaks uhdm-cmp's language.
        out=[];i=0
        while i<len(ls):
            if ls[i].strip()=='|vpiParent:': i+=2; continue
            if ls[i].strip().startswith('|vpiFullName:'): i+=1; continue
            out.append(ls[i]); i+=1
        ls=out
    return ls
def cells(lines, pat):
    out={}
    if lines is None: return out
    for i,l in enumerate(lines):
        m=re.search(r'\\_(function|task): \([^)]*[.:]('+pat+r')\)',l)
        if not m: continue
        nm=m.group(2)
        if nm in out: continue
        ind=len(l)-len(l.lstrip()); j=i+1
        while j<len(lines):
            s=lines[j]
            if not s.strip(): j+=1; continue
            if len(s)-len(s.lstrip())<=ind: break
            j+=1
        out[nm]='\n'.join(x.strip() for x in lines[i:j])
    return out
def main():
    d=sys.argv[1]; pat=sys.argv[2]
    sfx='e' if os.environ.get('VIEW')=='elab' else ''
    g=load(os.path.join(d,'g%s.dump'%sfx),d); o=load(os.path.join(d,'o%s.dump'%sfx),d); q=load(os.path.join(d,'q%s.dump'%sfx),d)
    G,O,Q=cells(g,pat),cells(o,pat),cells(q,pat)
    tally={}
    names=sorted(set(G)|set(O)|set(Q))
    for n in names:
        gg,oo,qq=G.get(n),O.get(n),Q.get(n)
        if gg is None: v='NOGOLDEN'
        elif oo==gg and qq==gg: v='RIGHT'
        elif oo!=gg and qq==gg: v='FIXED'
        elif oo==gg and qq!=gg: v='BROKEN'
        elif oo==qq: v='UNMOVED'
        else: v='MOVEDWRONG'
        tally[v]=tally.get(v,0)+1
        print('%-12s %s'%(v,n))
    print('-- '+os.path.basename(d)+' '+' '.join('%s=%d'%(k,tally[k]) for k in sorted(tally)))
main()
