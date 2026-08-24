#!/usr/bin/env python3
# r10uvm119repro/cen119.py -- the MEMBER-RANDOMIZE CENSUS.  MEASUREMENT ONLY.
#
# Read off a `uhdm-dump` text tree, which is exactly the REACHABLE tree, so no
# row can name an object the judge cannot see (uvm97's AllObjects trap).  The
# parse is STREAMING (only the ancestor stack is held) because a UVM dump is
# ~100 MB.
#
# WHY NOT r10uvm116repro/cen116.py, WHICH IS COMMITTED AND WOULD OTHERWISE DO.
# cen116's `interesting()` emits a `hier_path` when THE PATH'S OWN NAME mentions
# `randomize`.  That name is exactly what § memberRandomizeWithIsRecvPath119
# REMOVES: after the fix our path is named `seq_or_item`, so every cell this
# pass touches would silently LEAVE the census and the totals would read
# "fewer differing rows" for the wrong reason.  That is uvm109's rule -- a pass
# that REMOVES objects must score one-sided sets -- so this census decides
# whether a path is interesting from ITS ELEMENTS (does the path carry a step
# named `randomize`?), a property neither side's naming can change, and the
# decision is therefore taken at POP time rather than when the name is read.
#
#   row = FORM \t TAG \t KEY \t VALUE
#
#   FORM   HP        a `hier_path` carrying a `randomize` step  (the member form)
#          MFC       a `method_func_call`/`func_call` named `randomize` that is
#                    NOT inside such a path (the scope form, uvm116's)
#          REF       a `ref_obj` whose name mentions randomize (Surelog's
#                    `std::randomize` garbage)
#          CONS      a `constraint` object (named or not)
#   KEY    <nearest named ancestor>@<START of the object>   -- START ONLY,
#          never the end: golden's path runs through the constraint block's
#          `}` and ours stopped at the invocation's `)`, so an end-bearing key
#          would refuse to join the two sides of the very cell being measured.
#          The FILE is never in the key (our objects carry an empty VpiFile).
#          A `constraint` has no name and no span, and its nearest named
#          ancestor is the call named `randomize`, so the plain key would
#          collapse every constraint in a database into one cell; those rows
#          are keyed on the dump's SYNTHESISED fullname instead.  That is a
#          parent-chain reading, which is what it should be: if our parenting
#          of a constraint stopped matching golden's the two sides would stop
#          joining and the census would SAY so rather than hide it.
#   VALUE  kind(name)@span{field=child,...}  -- two levels deep
#
# LHS is ALWAYS golden.
import sys, re

NODE  = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?, (?:id:\d+, )?line:(\d+):(\d+), endln:(\d+):(\d+)')
NODE2 = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?(?:, id:\d+)?\s*$')
FIELD = re.compile(r'^(\s*)\|(\w+):(.*)$')

class N:
    __slots__ = ('kind','name','span','indent','field','vname','kids','parent','inpath')
    def __init__(s, kind, name, span, indent):
        s.kind=kind; s.name=name; s.span=span; s.indent=indent
        s.field=None; s.vname=''; s.kids=[]; s.parent=None; s.inpath=False

def sp(n): return '%d:%d-%d:%d' % n.span if n.span else '-'
def start(n): return '%d:%d' % (n.span[0], n.span[1]) if n.span else '-'
def nm(n): return n.vname or n.name or ''

def scope(n):
    p = n.parent
    while p is not None:
        if nm(p): return nm(p)
        p = p.parent
    return '-'

def randstep(n):
    """A hier_path is this census's business when one of its ELEMENTS is named
    `randomize` -- a property no naming law of ours can change."""
    for _, c in n.kids:
        if 'randomize' in nm(c) and c.kind in ('method_func_call','func_call','ref_obj'):
            return True
    return False

def interesting(n):
    if n.kind == 'constraint':
        return True
    if n.kind == 'hier_path':
        return randstep(n) or 'randomize' in nm(n)
    if n.kind in ('method_func_call','func_call','ref_obj'):
        # a step INSIDE a counted hier_path is reported as part of that path's
        # VALUE, never as a row of its own (it would double-count the cell).
        return 'randomize' in nm(n) and not n.inpath
    return False

def key(n):
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
    path, tag = sys.argv[1], sys.argv[2]
    stack, rows = [], []
    def pop(n):
        if interesting(n):
            rows.append('%s\t%s\t%s\t%s' % (form(n), tag, key(n), desc(n)))
    for line in open(path, 'rt', errors='replace'):
        line = line.rstrip('\n')
        m = NODE.match(line); m2 = None if m else NODE2.match(line)
        if m or m2:
            g = m or m2
            ind = len(g.group(1))
            span = (int(m.group(4)), int(m.group(5)), int(m.group(6)), int(m.group(7))) if m else None
            n = N(g.group(2), g.group(3) or '', span, ind)
            while stack and stack[-1].indent >= ind:
                pop(stack.pop())
            fld = stack[-1].field if stack else None
            if stack:
                n.parent = stack[-1]
                # a vpiParent block is a BACK-reference, never a child
                if fld != 'vpiParent':
                    stack[-1].kids.append((fld or '?', n))
                    if stack[-1].kind == 'hier_path':
                        n.inpath = True
            stack.append(n)
            continue
        f = FIELD.match(line)
        if f:
            ind = len(f.group(1))
            while stack and stack[-1].indent >= ind:
                pop(stack.pop())
            if not stack: continue
            stack[-1].field = f.group(2)
            if f.group(2) == 'vpiName' and f.group(3):
                stack[-1].vname = f.group(3)
            if f.group(2) == 'vpiFullName' and not stack[-1].name:
                stack[-1].name = f.group(3)
    while stack:
        pop(stack.pop())
    rows.sort()
    for r in rows: print(r)

main()
