#!/usr/bin/env python3
# r10uvm116repro/cen116.py -- the RANDOMIZE CENSUS.  MEASUREMENT ONLY.
#
# Read off a `uhdm-dump` text tree, which is exactly the REACHABLE tree, so no
# row can name an object the judge cannot see (uvm97's AllObjects trap).  The
# parse is STREAMING (only the ancestor stack is held) because a UVM dump is
# ~100 MB.
#
#   row = FORM \t KEY \t VALUE
#
#   FORM   MFC       a bare `method_func_call` named `randomize`
#          HP        a `hier_path` that carries a `randomize` step
#          REF       a `ref_obj` whose name mentions randomize (Surelog's
#                    std::randomize garbage)
#          CONS      a `constraint` object (named or not)
#   KEY    <nearest named ancestor>@<START of the object>   -- START ONLY,
#          never the end: golden's call runs through the constraint block's
#          `}` and ours stops at the invocation's `)`, so an end-bearing key
#          would refuse to join the two sides of the very cell being measured.
#          The FILE is never in the key (our objects carry an empty VpiFile).
#   VALUE  kind(name)|args=<...>|with=<...>|span=<full span>
#
# LHS is ALWAYS golden.
import sys, re, os

NODE  = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?, (?:id:\d+, )?line:(\d+):(\d+), endln:(\d+):(\d+)')
NODE2 = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?(?:, id:\d+)?\s*$')
FIELD = re.compile(r'^(\s*)\|(\w+):(.*)$')

WANTED = ('randomize',)

class N:
    __slots__ = ('kind','name','span','indent','field','vname','kids','parent','emit')
    def __init__(s, kind, name, span, indent):
        s.kind=kind; s.name=name; s.span=span; s.indent=indent
        s.field=None; s.vname=''; s.kids=[]; s.parent=None; s.emit=False

def sp(n):
    return '%d:%d-%d:%d' % n.span if n.span else '-'

def start(n):
    return '%d:%d' % (n.span[0], n.span[1]) if n.span else '-'

def nm(n):
    return n.vname or n.name or ''

def scope(n):
    p = n.parent
    while p is not None:
        if nm(p): return nm(p)
        p = p.parent
    return '-'

def interesting(n):
    if n.kind == 'constraint': return True
    v = nm(n)
    if 'randomize' in v and n.kind in ('method_func_call','hier_path','ref_obj','func_call'):
        return True
    return False

def key(n):
    # A `constraint` has NO name and NO span, and its nearest named ancestor is
    # the call named `randomize` — so the plain key collapses EVERY constraint
    # in a database into one cell and a census row can then read "changed" when
    # the truth is "three of five now present".  Its SYNTHESISED fullname (the
    # dump's parenthesised header, walked up the parent chain) is the only
    # thing that separates the sites, so that is the key here.  It is a
    # PARENT-CHAIN reading, which is exactly right: if our parenting of the
    # constraint ever stopped matching golden's, the two sides would stop
    # joining and the census would say so instead of hiding it.
    if n.kind == 'constraint':
        return '%s@%s' % (n.name or '-', start(n))
    return '%s@%s' % (scope(n), start(n))

def form(n):
    if n.kind == 'constraint': return 'CONS'
    if n.kind == 'hier_path': return 'HP'
    if n.kind == 'ref_obj': return 'REF'
    return 'MFC'

def desc(n, d=0):
    if d > 2: return '...'
    inner = ''
    if n.kids and d < 2:
        inner = '{' + ','.join('%s=%s' % (f, desc(c, d+1)) for f, c in n.kids) + '}'
    return '%s(%s)@%s%s' % (n.kind, nm(n), sp(n), inner)

def main():
    path = sys.argv[1]
    tag  = sys.argv[2]
    stack = []          # list of N, increasing indent
    rows = []
    keep = []           # nodes whose subtree we are collecting
    for line in open(path, 'rt', errors='replace'):
        line = line.rstrip('\n')
        m = NODE.match(line); m2 = None if m else NODE2.match(line)
        if m or m2:
            g = m or m2
            ind = len(g.group(1))
            span = (int(m.group(4)), int(m.group(5)), int(m.group(6)), int(m.group(7))) if m else None
            n = N(g.group(2), g.group(3) or '', span, ind)
            while stack and stack[-1].indent >= ind:
                done = stack.pop()
                if done.emit:
                    rows.append('%s\t%s\t%s\t%s' % (form(done), tag,
                                                   key(done), desc(done)))
            fld = stack[-1].field if stack else None
            if stack:
                n.parent = stack[-1]
                # a vpiParent block is a BACK-reference, never a child
                if fld != 'vpiParent':
                    stack[-1].kids.append((fld or '?', n))
            stack.append(n)
            continue
        f = FIELD.match(line)
        if f:
            ind = len(f.group(1))
            while stack and stack[-1].indent >= ind:
                done = stack.pop()
                if done.emit:
                    rows.append('%s\t%s\t%s\t%s' % (form(done), tag,
                                                   key(done), desc(done)))
            if not stack: continue
            stack[-1].field = f.group(2)
            if f.group(2) == 'vpiName' and f.group(3):
                stack[-1].vname = f.group(3)
                if interesting(stack[-1]): stack[-1].emit = True
            if f.group(2) == 'vpiFullName' and not stack[-1].name:
                stack[-1].name = f.group(3)
            # a `constraint` never carries a vpiName -- catch it on its own line
            if stack[-1].kind == 'constraint': stack[-1].emit = True
    while stack:
        done = stack.pop()
        if done.emit:
            rows.append('%s\t%s\t%s\t%s' % (form(done), tag,
                                               key(done), desc(done)))
    rows.sort()
    for r in rows: print(r)

main()
