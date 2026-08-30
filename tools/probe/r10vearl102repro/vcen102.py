#!/usr/bin/env python3
"""v102 VERIFIER CENSUS -- MEASUREMENT ONLY.
Parse a uhdm-dump text tree and emit one deduped row per RANGE BOUND whose
owner chain reaches a parameter / array_typespec / array_var / array_net,
keyed by (owner-fullname-chain, relation, dim-index, side) and carrying a
COMPARE-VISIBLE payload only (kind, opType, size, constType, decompile,
value, ref name+actual).  Spans go on a separate row and are never joined.
"""
import sys, re, collections

NODE = re.compile(r'^(\s*)\\_([a-zA-Z_0-9]+): (.*)$')
ATTR = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')

def parse(path):
    lines = open(path, errors='replace').read().split('\n')
    # stack of (indent, node)
    root = {'kind':'ROOT','attrs':{},'kids':[],'hdr':'','ind':-1,'parent':None}
    stack=[root]
    cur=root
    pend_attr=None
    for ln in lines:
        m=NODE.match(ln)
        if m:
            ind=len(m.group(1)); kind=m.group(2); hdr=m.group(3)
            while stack and stack[-1]['ind']>=ind: stack.pop()
            parent=stack[-1]
            n={'kind':kind,'attrs':{},'kids':[],'hdr':hdr,'ind':ind,'parent':parent,
               'rel':pend_attr}
            parent['kids'].append(n)
            stack.append(n); cur=n; pend_attr=None
            continue
        m=ATTR.match(ln)
        if m:
            ind=len(m.group(1)); k=m.group(2); v=m.group(3)
            while stack and stack[-1]['ind']>=ind: stack.pop()
            owner=stack[-1]
            if v=='':
                pend_attr=k
            else:
                owner['attrs'][k]=v
            cur=owner
            continue
    return root

def name_of(n):
    a=n['attrs']
    return a.get('vpiFullName') or a.get('vpiName') or ''

def hdrname(n):
    m=re.match(r'^([^,]*),', n['hdr'])
    s=m.group(1) if m else n['hdr']
    return s.strip()

def payload(n):
    a=n['attrs']
    p=[n['kind']]
    for k in ('vpiOpType','vpiSize','vpiConstType','vpiDecompile','vpiName'):
        if k in a: p.append(k+'='+a[k])
    for k in a:
        if k.startswith(('INT:','UINT:')): pass
    # value lines are dumped bare as e.g. |INT:1 -> they land as attrs key 'INT' value '1'
    for k in ('INT','UINT','STRING','BIN','HEX','REAL','SCAL'):
        if k in a: p.append(k+':'+a[k])
    # operands / actual
    for kid in n['kids']:
        if kid['rel']=='vpiOperand':
            p.append('opnd{'+payload(kid)+'}')
        if kid['rel']=='vpiActual':
            p.append('act{'+kid['kind']+':'+hdrname(kid)+'}')
    return ','.join(p)

def owner_chain(n):
    out=[]
    p=n['parent']
    depth=0
    while p is not None and depth<12:
        nm=name_of(p) or hdrname(p)
        out.append(p['kind']+('('+nm+')' if nm else ''))
        p=p['parent']; depth+=1
    return '<'.join(out)

def walk(n, out):
    if n['kind']=='range':
        for side in ('vpiLeftRange','vpiRightRange'):
            for kid in n['kids']:
                if kid['rel']==side:
                    span=re.sub(r'^[^,]*,\\s*','',n['hdr']).strip()
                    key=owner_chain(n)+'|'+span+'|'+side
                    out.append((key, payload(kid)))
    for k in n['kids']:
        walk(k,out)

def main():
    root=parse(sys.argv[1])
    rows=[]
    walk(root,rows)
    c=collections.Counter(rows)
    for (k,v),n in sorted(c.items()):
        print(f'{n}\t{k}\t{v}')

main()
