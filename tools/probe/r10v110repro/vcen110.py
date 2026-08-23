#!/usr/bin/env python3
# r10v110 -- MEASUREMENT ONLY.  A VIEW-GENERAL assignment-lvalue census read off
# a uhdm-dump text tree.  Keyed on the assignment's START LINE (arms are one
# cell per line, and golden and ours agree on statement lines) plus the nearest
# named ancestor's LEAF name, so a cell can be named in the report.
# The VALUE carries EVERY judge-visible axis of the Lhs subtree that
# <kind>::Compare reads: object KIND, VpiName LEAF, VpiDefName, VpiDecompile,
# VpiSize, the ref's vpiActual (kind + leaf name), a hier_path's Path_elems,
# and the typespec's kind + leaf name.  NO VpiFullName, NO file/line/col
# (no generated Compare reads them).
import sys, re, os
NODE  = re.compile(r'^(\s*)\\_(\w+): (?:([^,]*?) )?\(([^)]*)\)?, .*?line:(\d+):(\d+), endln:(\d+):(\d+)')
NODEA = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?,.*?line:(\d+):(\d+), endln:(\d+):(\d+)')
NODE2 = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?\s*$')
FIELD = re.compile(r'^(\s*)\|(\w+):(.*)$')
class N:
    __slots__=('kind','name','line','fields','indent','parent','pfield')
    def __init__(s,kind,name,line,indent):
        s.kind=kind; s.name=name; s.line=line; s.fields={}; s.indent=indent
        s.parent=None; s.pfield=None
def parse(path):
    roots=[]; stack=[]
    for line in open(path,'rt',errors='replace'):
        line=line.rstrip('\n')
        m=NODEA.match(line); m2=None if m else NODE2.match(line)
        if m or m2:
            g=m or m2
            ind=len(g.group(1))
            ln=int(m.group(4)) if m else 0
            n=N(g.group(2), g.group(3) or '', ln, ind)
            while stack and stack[-1][0]>=ind: stack.pop()
            if stack:
                n.parent=stack[-1][1]; n.pfield=stack[-1][2] or '?'
                stack[-1][1].fields.setdefault(n.pfield,[]).append(n)
            else: roots.append(n)
            stack.append([ind,n,None]); continue
        f=FIELD.match(line)
        if f:
            ind=len(f.group(1))
            while stack and stack[-1][0]>=ind: stack.pop()
            if not stack: continue
            stack[-1][2]=f.group(2)
            if f.group(3)!='':
                stack[-1][1].fields.setdefault(f.group(2),[]).append(f.group(3))
    return roots
def leaf(x): return x.rsplit('::',1)[-1].rsplit('.',1)[-1]
def kids(n):
    for k,v in n.fields.items():
        if k=='vpiParent': continue
        for c in v:
            if isinstance(c,N): yield k,c
def scal(n,f):
    for x in n.fields.get(f,[]):
        if not isinstance(x,N): return x
    return None
def render(n,depth=0,seen=None):
    if n is None: return '<none>'
    if depth>7: return '...'
    seen=seen or set()
    if id(n) in seen: return '<cyc>'
    seen=seen|{id(n)}
    s='%s(%s)'%(n.kind, leaf(n.name))
    dn=scal(n,'vpiDefName');  dc=scal(n,'vpiDecompile'); sz=scal(n,'vpiSize')
    vv=scal(n,'vpiValue');    ct=scal(n,'vpiConstType')
    for tag,val in (('DEF',dn),('DEC',dc),('SZ',sz),('VAL',vv),('CT',ct)):
        if val is not None: s+='%s=%s;'%(tag,val)
    ch=[]
    for k,c in kids(n):
        if k in ('vpiInstance','vpiModule','vpiTask','vpiFunction'): continue
        ch.append('%s:%s'%(k,render(c,depth+1,seen)))
    if ch: s+='{'+','.join(sorted(ch))+'}'
    return s
def namedanc(n):
    p=n.parent
    while p is not None:
        if p.name: return leaf(p.name)
        p=p.parent
    return '?'
def walk(n,out,seen):
    if id(n) in seen: return
    seen.add(id(n)); out.append(n)
    for k,c in kids(n): walk(c,out,seen)
CARRIERS={'assignment':'ASG','cont_assign':'CONTASG','assign_stmt':'ASGSTMT'}
def rows(path):
    roots=parse(path); alln=[]; seen=set()
    for r in roots: walk(r,alln,seen)
    out=[]
    for n in alln:
        site=CARRIERS.get(n.kind)
        if not site: continue
        l=r_=None
        for k,c in kids(n):
            if k=='vpiLhs': l=c
            elif k=='vpiRhs': r_=c
        val='LHS=%s | RHS=%s | OP=%s BLK=%s'%(
            render(l), render(r_,5), scal(n,'vpiOpType') or '-', scal(n,'vpiBlocking') or '-')
        out.append((site,'%s@L%d'%(namedanc(n),n.line),val))
    return out
if __name__=='__main__':
    for r in rows(sys.argv[1]): print('%s\t%s\t%s'%r)
