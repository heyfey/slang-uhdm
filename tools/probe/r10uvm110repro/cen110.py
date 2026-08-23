#!/usr/bin/env python3
# r10uvm110 -- MEASUREMENT ONLY.  The ASSIGNMENT-LVALUE census, read off a
# `uhdm-dump` text tree (the dump is exactly the REACHABLE tree, so no row can
# name an object the judge cannot see).
#
#   row = SITE \t KEY \t VALUE
#   SITE   ASG      an `assignment` node (procedural blocking/nonblocking/
#                   compound; Surelog emits all three as `assignment`)
#          CONTASG  a `cont_assign` (continuous), kept for calibration
#   KEY    <nearest named ancestor>@<span of the assignment>
#   VALUE  LHS=<rendered Lhs subtree> RHS=<rhs kind(name)> OP=<vpiOpType>
#          BLK=<vpiBlocking>
#   Spans are DUMP spans; no file, no source text (our objects carry no file).
#   LHS of the JOIN is ALWAYS golden.
#
# PROJ=1 projects every row onto the JUDGE-VISIBLE axes only: object KIND, the
# LEAF of any name (uhdm-dump SYNTHESISES vpiFullName from the parent chain and
# no generated `Compare` reads it), and the PRESENCE + KIND + LEAF NAME of a
# vpiActual.  Spans are dropped -- no generated `Compare` reads
# VpiFile/line/col.
import sys, re, os

PROJ = os.environ.get('PROJ') == '1'

NODE  = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?, line:(\d+):(\d+), endln:(\d+):(\d+)')
NODE2 = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?\s*$')
FIELD = re.compile(r'^(\s*)\|(\w+):(.*)$')

class N:
    __slots__ = ('kind','name','span','fields','indent','parent','pfield')
    def __init__(s, kind, name, span, indent):
        s.kind=kind; s.name=name; s.span=span
        s.fields={}; s.indent=indent; s.parent=None; s.pfield=None

def parse(path):
    roots=[]; stack=[]
    for line in open(path,'rt',errors='replace'):
        line=line.rstrip('\n')
        m=NODE.match(line); m2=None if m else NODE2.match(line)
        if m or m2:
            g=m or m2
            ind=len(g.group(1))
            span=((int(m.group(4)),int(m.group(5)),int(m.group(6)),int(m.group(7)))
                  if m else (0,0,0,0))
            n=N(g.group(2), g.group(3) or '', span, ind)
            while stack and stack[-1][0]>=ind: stack.pop()
            if stack:
                n.parent=stack[-1][1]; n.pfield=stack[-1][2] or '?'
                stack[-1][1].fields.setdefault(n.pfield,[]).append(n)
            else:
                roots.append(n)
            stack.append([ind,n,None])
            continue
        f=FIELD.match(line)
        if f:
            ind=len(f.group(1))
            while stack and stack[-1][0]>=ind: stack.pop()
            if not stack: continue
            stack[-1][2]=f.group(2)
            if f.group(3)!='':
                stack[-1][1].fields.setdefault(f.group(2),[]).append(f.group(3))
    return roots

def sp(n):
    return '.' if PROJ else '%d:%d-%d:%d'%n.span

def nm(x):
    return x.rsplit('::',1)[-1].rsplit('.',1)[-1] if PROJ else x

def kids(n):
    for k,v in n.fields.items():
        if k in ('vpiParent',): continue
        for c in v:
            if isinstance(c,N): yield k,c

def scal(n,f):
    v=n.fields.get(f)
    if not v: return None
    for x in v:
        if not isinstance(x,N): return x
    return None

def render(n, depth=0):
    if n is None: return '<none>'
    if depth>6: return '...'
    s='%s(%s)@%s'%(n.kind, nm(n.name), sp(n))
    if n.kind in ('ref_obj','ref_var'):
        acts=[c for k,c in kids(n) if k=='vpiActual']
        if acts:
            a=acts[0]
            s+='[ACT=%s(%s)@%s]'%(a.kind,nm(a.name),sp(a))
        else:
            s+='[ACT=-]'
    ch=[]
    for k,c in kids(n):
        if k=='vpiTypespec': continue
        # uhdm-dump prints a hier_path's Path_elems under the `vpiActual`
        # label; they are ELEMENTS, not an actual, so render them.
        if k=='vpiActual' and n.kind!='hier_path': continue
        ch.append('%s:%s'%('elem' if (k=='vpiActual' and n.kind=='hier_path') else k,
                           render(c,depth+1)))
    if ch: s+='{'+','.join(sorted(ch))+'}'
    return s

def namedanc(n):
    p=n.parent
    while p is not None:
        if p.name: return nm(p.name)
        p=p.parent
    return '?'

def walk(n, out):
    out.append(n)
    for k,c in kids(n):
        walk(c,out)

CARRIERS={'assignment':'ASG','cont_assign':'CONTASG','assign_stmt':'ASGSTMT'}

# DOTTED = the Lhs mentions more than one identifier: either a hier_path, or a
# ref_obj/var_select whose span covers more text than its own leaf name.
def lhs_of(n):
    for k,c in kids(n):
        if k=='vpiLhs': return c
    return None
def rhs_of(n):
    for k,c in kids(n):
        if k=='vpiRhs': return c
    return None

def rows(path):
    roots=parse(path)
    alln=[]
    for r in roots: walk(r,alln)
    out=[]
    for n in alln:
        site=CARRIERS.get(n.kind)
        if not site: continue
        l=lhs_of(n); r=rhs_of(n)
        op=scal(n,'vpiOpType') or '-'
        blk=scal(n,'vpiBlocking') or '-'
        val='LHS=%s RHS=%s OP=%s BLK=%s'%(
            render(l), ('<none>' if r is None else '%s(%s)'%(r.kind,nm(r.name))),
            op, blk)
        # PROJ drops the CARRIER SPAN from the key too: golden and ours differ
        # in assignment spans on shapes this pass does not touch, and a
        # span-keyed join reports those as LHS-ONLY / RHS-ONLY phantoms rather
        # than as the rows they are.  The join is a MULTISET join, so a
        # name-only key still compares the whole bag per named ancestor.
        key=(namedanc(n) if PROJ
             else '%s@%d:%d-%d:%d'%((namedanc(n),)+n.span))
        out.append((site,key,val))
    return out

if __name__=='__main__':
    for r in rows(sys.argv[1]):
        print('%s\t%s\t%s'%r)
