#!/usr/bin/env python3
"""r10earl61 -- PORT HighConn census over a uhdm-dump.

The dump is a COLUMN-INDENTED tree.  uhdm-dump keeps a GLOBAL visited set, so
every object's FULL subtree prints exactly ONCE (at the first place the walk
reaches it) and every later reference prints the HEADER LINE ALONE.  A
header-only print is therefore AMBIGUOUS (leaf vs re-reference) and is marked
`~` rather than counted as "no children".

For every `port` object it emits one row:

  section | owner-instance | port | hc-kind[opType] | ref-name=ACTUALKIND(name)|...

where the ref list is EVERY ref_obj in the High_conn subtree, depth-ordered,
and ACTUALKIND is `-` when the ref carries NO vpiActual (golden's <null>).
That is exactly the field `design::Compare` reads (Actual_group, singular).
"""
import re, sys, collections

HDR = re.compile(r'^( *)\\_([A-Za-z_0-9]+): (.*)$')
REL = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')

def norm(h):
    return re.sub(r', file:[^,]*', '', h)

def sectionof(rel):
    if rel.startswith('uhdmall'):  return 'DEF'
    if rel.startswith('uhdmtop'):  return 'ELAB'
    if rel == 'weaklyReferenced':  return 'TAIL'
    return None

class N:
    __slots__ = ('kind','hdr','attrs','kids','sec','col')
    def __init__(s, kind, hdr, sec, col):
        s.kind=kind; s.hdr=hdr; s.attrs={}; s.kids=[]; s.sec=sec; s.col=col

def parse(path):
    roots=[]; stack=[]; cur_rel=None; section='PRE'
    for line in open(path, errors='replace'):
        line=line.rstrip('\n')
        if line=='\\_weaklyReferenced:':
            stack=[]; section='TAIL'; cur_rel=None; continue
        m=HDR.match(line)
        if m:
            col=len(m.group(1)); kind=m.group(2); hdr=norm(m.group(3))
            if col==0:
                s=sectionof(cur_rel or '')
                if s: section=s
            while stack and stack[-1][0].col>=col: stack.pop()
            n=N(kind,hdr,section,col)
            if stack: stack[-1][0].kids.append((stack[-1][1] or '?', n))
            else: roots.append(n)
            stack.append([n,None])
            cur_rel=None
            continue
        m=REL.match(line)
        if m:
            col=len(m.group(1)); tag=m.group(2); val=m.group(3)
            if col==0:
                cur_rel=tag; continue
            while stack and stack[-1][0].col>=col: stack.pop()
            if val=='':
                if stack: stack[-1][1]=tag
                cur_rel=tag
            else:
                if stack: stack[-1][0].attrs[tag]=val; stack[-1][1]=None
                cur_rel=None
            continue
    return roots

def nm(n):
    m=re.match(r'^(?:([^ ]+) )?\((.*?)\)', n.hdr)
    if m: return m.group(2)
    return n.attrs.get('vpiName','')

BINDABLE = ('ref_obj','ref_var','bit_select','part_select',
            'indexed_part_select','hier_path','var_select')

def refs_in(n, out, depth=0):
    """every BINDABLE object in the subtree, depth-ordered.  `Actual_group`
    is the ONLY field design::Compare reads here, and selects carry it too."""
    if n.kind in BINDABLE:
        act='-'
        for rel,k in n.kids:
            if rel=='vpiActual':
                # design::Compare reads the actual's VpiType and VpiName --
                # NEVER its VpiFullName -- so the key carries kind+name only.
                act='%s(%s)' % (k.kind,
                                k.attrs.get('vpiName', nm(k).split('.')[-1]))
        if not n.kids and not n.attrs:
            act='~HDRONLY'   # re-reference print: NOT evidence of a null edge
        out.append((depth, n.attrs.get('vpiName','') or nm(n).split('.')[-1],
                    act, n.kind))
    for rel,k in n.kids:
        if rel in ('vpiActual','vpiTypespec','vpiParent'): continue
        refs_in(k,out,depth+1)

def hckind(h):
    op = h.attrs.get('vpiOpType','')
    return h.kind + (('[op%s]'%op) if op else '')

def walk(n, ownstack, rows):
    own = ownstack[-1] if ownstack else '?'
    push = None
    if n.kind in ('module_inst','interface_inst','gen_scope','program'):
        push = nm(n)
        ownstack.append(push)
    if n.kind=='port':
        hc=None
        for rel,k in n.kids:
            if rel=='vpiHighConn': hc=k
        if hc is not None:
            rl=[]; refs_in(hc,rl)
            rs='|'.join('%s:%s=%s'%(r[3],r[1] or '<>',r[2]) for r in rl) or '<norefs>'
            rows.append((n.sec, ownstack[-1] if ownstack else '?',
                         n.attrs.get('vpiName',''), hckind(hc), rs))
    for rel,k in n.kids:
        if rel in ('vpiActual','vpiTypespec'): continue
        walk(k, ownstack, rows)
    if push is not None: ownstack.pop()

if __name__=='__main__':
    roots=parse(sys.argv[1])
    rows=[]
    for r in roots: walk(r, [], rows)
    for r in rows:
        print('%s\t%s\t%s\t%s\t%s' % r)
    sys.stderr.write('%s: %d port-highconn rows\n' % (sys.argv[1], len(rows)))
