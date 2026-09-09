#!/usr/bin/env python3
"""Roster of an instance definition's Nets/Array_nets/Variables/Process from a
uhdm-dump, with each net's typespec ACTUAL kind.  Measurement only."""
import re,sys

def build(path):
    root={'kind':'ROOT','name':'','children':[],'fields':{},'label':None}
    stack=[(-1,root)]
    pend=None
    for raw in open(path,errors='replace'):
        line=raw.rstrip('\n')
        body=line.lstrip(' ')
        ind=len(line)-len(body)
        if body.startswith('\\_'):
            rest=body[2:]
            kind=rest.split(':',1)[0]
            after=rest.split(':',1)[1] if ':' in rest else ''
            nm=''
            m=re.match(r'\s*([^,]*)',after)
            if m: nm=m.group(1).strip()
            node={'kind':kind,'name':nm,'children':[],'fields':{},'label':pend,'loc':after}
            while stack and stack[-1][0]>=ind: stack.pop()
            stack[-1][1]['children'].append(node)
            stack.append((ind,node))
            pend=None
        elif body.startswith('|'):
            t=body[1:]
            if t.endswith(':') and ':' in t:
                pend=t[:-1]
            else:
                k,_,v=t.partition(':')
                while stack and stack[-1][0]>=ind: stack.pop()
                stack[-1][1]['fields'][k]=v
                pend=None
    return root

def find(node,pred,out):
    if pred(node): out.append(node)
    for c in node['children']: find(c,pred,out)

def kids(n,label):
    return [c for c in n['children'] if c['label']==label]

def tsof(n):
    ts=kids(n,'vpiTypespec')
    if not ts: return '-'
    a=kids(ts[0],'vpiActual')
    if not a: return ts[0]['kind']+'->?'
    return a[0]['kind']+(' '+a[0]['name'] if a[0]['name'] else '')

def report(path,names):
    root=build(path)
    got=[]
    find(root,lambda n:n['kind'] in ('interface_inst','module_inst','program','package') and (not names or any(n['name'].startswith(x) for x in names)),got)
    best={}
    for n in got:
        key=(n['kind'],n['name'])
        if key not in best or len(n['children'])>len(best[key]['children']): best[key]=n
    for key in sorted(best,key=lambda k:(k[0],k[1])):
        n=best[key]
        print('== %s %s'%(n['kind'],n['name']))
        for lab,tag in (('vpiNet','NET'),('vpiArrayNet','ARRAYNET'),('vpiVariables','VAR'),('vpiProcess','PROC')):
            for c in kids(n,lab):
                nm=c['fields'].get('vpiName','')
                extra=''
                if tag=='ARRAYNET':
                    inner=kids(c,'vpiNet')
                    extra=' inner_ts=%s size=%s'%(tsof(inner[0]) if inner else 'NONE', c['fields'].get('vpiSize',''))
                    rg=kids(c,'vpiRange')
                    extra+=' nranges=%d'%len(rg)
                print('  %-9s %-16s kind=%-12s ts=%s%s'%(tag,nm or c['kind'],c['kind'],tsof(c),extra))


def roster(path):
    """{(holderkind, holdername, section, netname): (objkind, ts, extra)}"""
    root=build(path)
    got=[]
    find(root,lambda n:n['kind'] in ('interface_inst','module_inst','program','package'),got)
    best={}
    for n in got:
        key=(n['kind'],n['name'])
        if key not in best or len(n['children'])>len(best[key]['children']): best[key]=n
    out={}
    for (hk,hn),n in best.items():
        for lab,tag in (('vpiNet','NET'),('vpiArrayNet','ARRAYNET'),('vpiVariables','VAR'),('vpiProcess','PROC')):
            for i,c in enumerate(kids(n,lab)):
                nm=c['fields'].get('vpiName','') or ('#%d'%i)
                extra=''
                if tag=='ARRAYNET':
                    inner=kids(c,'vpiNet')
                    extra='inner_ts=%s'%(tsof(inner[0]) if inner else 'NONE')
                out[(hk,hn,tag,nm)]=(c['kind'],tsof(c),extra)
    return out

def compare(gpath,opath,label=''):
    g=roster(gpath); o=roster(opath)
    keys=sorted(set(g)|set(o))
    same=miss=extra=diff=0
    lines=[]
    for k in keys:
        gv=g.get(k); ov=o.get(k)
        if gv is None:
            extra+=1; lines.append('  OURS-ONLY   %s %s'%(k,ov))
        elif ov is None:
            miss+=1; lines.append('  GOLDEN-ONLY %s %s'%(k,gv))
        elif gv!=ov:
            diff+=1; lines.append('  DIFF        %s\n      golden=%s\n      ours  =%s'%(k,gv,ov))
        else:
            same+=1
    print('%s SAME=%d DIFF=%d GOLDEN-ONLY=%d OURS-ONLY=%d  (cells_wrong=%d)'%(label,same,diff,miss,extra,diff+miss+extra))
    for l in lines: print(l)
    return diff+miss+extra

if __name__=='__main__':
    if sys.argv[1]=='--cmp':
        sys.exit(0 if compare(sys.argv[2],sys.argv[3],sys.argv[4] if len(sys.argv)>4 else '')==0 else 1)
    report(sys.argv[1],sys.argv[2:])
