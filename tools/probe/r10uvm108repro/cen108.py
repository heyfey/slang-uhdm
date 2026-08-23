#!/usr/bin/env python3
# r10uvm108 — MEASUREMENT ONLY.  The EVENT-CONTROL OPERAND census, read off a
# `uhdm-dump` text tree (the dump is exactly the REACHABLE tree, so no row can
# name an object the judge cannot see).
#
#   row = SITE \t KEY \t VALUE
#   SITE   EVCTRL   an event_control's vpiCondition subtree
#          WAITSTM  a wait_stmt's vpiCondition subtree
#          EVSTMT   an event_stmt's vpiName/operand (the `-> e` trigger)
#   KEY    <nearest named ancestor>@<span of the CARRIER>
#   VALUE  the condition tree rendered as kind(name)@span{children},
#          each ref_obj annotated ACT=<actual kind>(<actual name>@<span>) or
#          ACT=- when it carries no vpiActual.
# Spans are DUMP spans; no file, no source text (our objects carry no file).
# LHS is ALWAYS golden.
import sys, re, collections, os
# PROJ=1 projects every row onto the JUDGE-VISIBLE axes only: object KIND,
# the LEAF of any name (uhdm-dump synthesises vpiFullName from the parent
# chain and `Compare` never reads it), and the PRESENCE + KIND + LEAF NAME of
# a vpiActual.  Spans are dropped too -- no generated `Compare` reads
# VpiFile/line/col.
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

def render(n, depth=0):
    if depth>6: return '...'
    s='%s(%s)@%s'%(n.kind, nm(n.name), sp(n))
    if n.kind=='ref_obj' or n.kind=='ref_var':
        acts=[c for k,c in kids(n) if k=='vpiActual']
        if acts:
            a=acts[0]
            s+='[ACT=%s(%s)@%s]'%(a.kind,nm(a.name),sp(a))
        else:
            s+='[ACT=-]'
    ch=[]
    for k,c in kids(n):
        if k=='vpiTypespec': continue
        # uhdm-dump prints a hier_path's Path_elems under the `vpiActual` label;
        # they are ELEMENTS, not an actual, so render them.
        if k=='vpiActual' and n.kind!='hier_path': continue
        ch.append('%s:%s'%('elem' if (k=='vpiActual' and n.kind=='hier_path') else k,
                           render(c,depth+1)))
    if ch: s+='{'+','.join(sorted(ch))+'}'
    return s

def namedanc(n):
    p=n.parent
    while p is not None:
        if p.name: return p.name
        p=p.parent
    return '?'

def walk(n, out):
    out.append(n)
    for k,c in kids(n):
        walk(c,out)

CARRIERS={'event_control':'EVCTRL','wait_stmt':'WAITSTM','event_stmt':'EVSTMT'}

def rows(path):
    roots=parse(path)
    alln=[]
    for r in roots: walk(r,alln)
    out=[]
    for n in alln:
        site=CARRIERS.get(n.kind)
        if not site: continue
        conds=[c for k,c in kids(n) if k=='vpiCondition']
        if n.kind=='event_stmt':
            conds=[c for k,c in kids(n) if k in ('vpiCondition','vpiExpr','vpiStmt')]
        val=';'.join(render(c) for c in conds) if conds else '<nocond>'
        key='%s@%d:%d-%d:%d'%((namedanc(n),)+n.span)
        out.append((site,key,val))
    return out

if __name__=='__main__':
    for r in rows(sys.argv[1]):
        print('%s\t%s\t%s'%r)
