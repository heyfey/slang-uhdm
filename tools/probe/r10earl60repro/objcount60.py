#!/usr/bin/env python3
"""r10earl60 — FULL-PRINT object population census over a uhdm-dump, keyed
(section, kind, normalised header) with a flag for whether the object carries a
|vpiInstance: child.  A dump object with NO child lines is AMBIGUOUS (genuine
leaf vs a shallow re-reference of an already-visited object), so it is counted
in its own SHALLOW bucket and never mixed with the full prints."""
import re, sys, collections
HDR = re.compile(r'^( *)\\_([A-Za-z_0-9]+): (.*)$')
REL = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
def norm(h): return re.sub(r', file:[^,]*', '', h)
def sectionof(rel):
    if rel.startswith('uhdmall'): return 'DEF'
    if rel.startswith('uhdmtop'): return 'ELAB'
    if rel == 'weaklyReferenced': return 'TAIL'
    return None
def run(path, outp):
    stack=[]; cur_rel=None; section='PRE'
    full=collections.Counter(); shal=collections.Counter()
    def close(fin):
        key=(fin[5], fin[1], fin[2])
        if fin[3]==0: shal[key]+=1
        else: full[key+(fin[6],)]+=1
    for line in open(path, errors='replace'):
        line=line.rstrip('\n')
        if line == '\\_weaklyReferenced:':
            while stack: close(stack.pop())
            section='TAIL'; cur_rel=None; continue
        m=HDR.match(line)
        if m:
            col=len(m.group(1)); kind=m.group(2); hdr=norm(m.group(3))
            if col==0:
                s=sectionof(cur_rel or '')
                if s: section=s
            while stack and stack[-1][0]>=col: close(stack.pop())
            if stack:
                stack[-1][3]+=1
                if stack[-1][4]=='vpiInstance': stack[-1][6]=kind+'|'+hdr
            stack.append([col,kind,hdr,0,cur_rel,section,'-'])
            cur_rel=None; continue
        m=REL.match(line)
        if m:
            col=len(m.group(1)); tag=m.group(2); val=m.group(3)
            if col==0: cur_rel=tag; continue
            while stack and stack[-1][0]>=col: close(stack.pop())
            if val=='':
                cur_rel=tag
                if stack: stack[-1][4]=tag
            else:
                if stack: stack[-1][3]+=1; stack[-1][4]=None
                cur_rel=None
            continue
    while stack: close(stack.pop())
    with open(outp,'w') as f:
        for k,v in sorted(full.items()): f.write('F\t%s\t%s\t%s\t%s\t%d\n'%(k[0],k[1],k[2],k[3],v))
        for k,v in sorted(shal.items()): f.write('S\t%s\t%s\t%s\t-\t%d\n'%(k[0],k[1],k[2],v))
    print(path,'full',sum(full.values()),'shallow',sum(shal.values()))
run(sys.argv[1], sys.argv[2])
