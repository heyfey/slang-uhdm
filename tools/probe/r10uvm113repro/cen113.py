#!/usr/bin/env python3
"""r10uvm113 — join two ct113cen censuses (golden, ours) into per-cell verdicts.

MEASUREMENT ONLY.  The official uhdm-cmp is the judge.

Key: (VIEW, TOP, HOME, CALL, line:col span WITHOUT the file, KIND).
The file part is dropped because OUR objects carry an EMPTY VpiFile
(a standing fact of this emitter) — keying on it would make every cell a
one-sided row.  Keys can collide (a macro expanded twice at one span), so the
join is a MULTISET join: both sides are bucketed and the buckets are compared
by sorted value list, never by a last-writer dict.

Verdicts per cell:
  SAME        both sides bind the same callee shape
  OURS-NULL   golden binds, we bind nothing        <- the head's family
  GOLD-NULL   we bind, golden binds nothing
  DIFF        both bind, different callee shape
  ONLY-G/ONLY-O   the cell exists on one side only
"""
import sys, os, collections

# END-SPAN TRAP: a macro-expanded call's END column differs between the two
# producers (golden 132:8-132:223 vs ours 132:8-132:243 for one `uvm_warning),
# and Compare never reads a span at all.  Keying on the full span turned 1861
# matched cells into one-sided rows.  KEY113=full restores the strict key.
#   KEY113=nospan (the DEFAULT) drops the span from the key AND from the callee
# shape, because the two producers also disagree about macro-expansion LINES
# (golden reports the macro BODY line uvm_message_defines.svh:133, we report the
# USE line uvm_component.svh:1887).  Compare reads no span, so a span in the key
# manufactures one-sided phantoms; the bucket (view, top, home, call, kind) with
# a MULTISET of callee shapes is the judge-visible cell.
MODE113 = os.environ.get('KEY113', 'nospan')
KEYSTART = MODE113 == 'start'
NOSPAN = MODE113 == 'nospan'

def load(path):
    d = collections.defaultdict(list)
    with open(path) as f:
        for ln in f:
            p = ln.rstrip('\n').split('\t')
            if len(p) != 7: continue
            view, top, home, call, sp, kind, callee = p
            sp = sp.split(':', 1)[1] if ':' in sp else sp   # drop the file
            if KEYSTART: sp = ':'.join(sp.split(':')[:2])   # start line:col only
            if NOSPAN: sp = '-'
            d[(view, top, home, call, sp, kind)].append(callee)
    return d

def shape(c):
    """callee descriptor -> comparable shape across producers (ids/files differ).
    kind|name|parentkind:parentname@file:span  ->  kind|name|parentkind:parentname@span"""
    if c == '<null>': return c
    k, _, rest = c.partition('|')
    nm, _, rest2 = rest.partition('|')
    par, _, loc = rest2.partition('@')
    loc = loc.split(':', 1)[1] if ':' in loc else loc
    if KEYSTART: loc = ':'.join(loc.split(':')[:2])
    if NOSPAN: return '%s|%s|%s' % (k, nm, par)
    return '%s|%s|%s@%s' % (k, nm, par, loc)

def main():
    g, o = load(sys.argv[1]), load(sys.argv[2])
    tag = sys.argv[3] if len(sys.argv) > 3 else ''
    counts = collections.Counter()
    rows = []
    for k in set(g) | set(o):
        gv = sorted(shape(x) for x in g.get(k, []))
        ov = sorted(shape(x) for x in o.get(k, []))
        n = max(len(gv), len(ov))
        for i in range(n):
            a = gv[i] if i < len(gv) else None
            b = ov[i] if i < len(ov) else None
            if a is None: v = 'ONLY-O'
            elif b is None: v = 'ONLY-G'
            elif a == b: v = 'SAME'
            elif b == '<null>': v = 'OURS-NULL'
            elif a == '<null>': v = 'GOLD-NULL'
            else: v = 'DIFF'
            counts[v] += 1
            if v != 'SAME':
                rows.append((v, k, a, b))
    for v, c in sorted(counts.items()):
        print('COUNT\t%s\t%s\t%d' % (tag, v, c))
    for v, k, a, b in sorted(rows):
        print('CELL\t%s\t%s\t%s\tG=%s\tO=%s' % (tag, v, '\t'.join(k), a, b))

main()
