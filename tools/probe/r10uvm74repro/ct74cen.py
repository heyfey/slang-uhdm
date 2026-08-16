#!/usr/bin/env python3
"""r10uvm74 — CENSUS of INDEXED HIER_PATH STEPS, both sides, span-keyed.

THE POPULATION: every object printed by uhdm-dump whose decompiled text is a
SINGLE indexed component -- `base[idx]`, one pair of brackets, NO dot -- that
sits DIRECTLY UNDER a hier_path (i.e. is a Path_elems entry).  That is exactly
the family the head lives in: golden makes it a `bit_select` spanning the BASE
NAME ALONE with a `vpiIndex` child, we (sometimes) make one flat `ref_obj`
spanning the whole written component.

WHY THE KEY IS (text, START span) AND NOT (text, WHOLE span).
The whole point of this pass is that the two sides DISAGREE about the END
column (golden 554:46, ours 554:49), so a key that includes the end column
would never join the two sides and the census would report "no shared keys"
-- i.e. it would read as green while measuring nothing.  The START is the
one coordinate both sides agree on by construction (both anchor at the base
name token).  r10uvm73's README records the dual trap -- a BARE span is not a
key either, because a macro body's line numbers travel with each expansion --
so the TEXT is carried in the key alongside the start.

WHAT IS RECORDED PER KEY: the merged set of object KINDS, the merged set of
END columns, whether any print carried a `vpiIndex`, and the enclosing
hier_path's name (read off the `|vpiParent:` line that follows).  A census
that tested KIND alone would read a bit_select with no index child as green.

  usage: ct74cen.py <golden.dump> <ours.dump> [--diff] [--list]
"""
import re
import sys
from collections import defaultdict

OBJ = re.compile(r'^(\s*)\\_(\w+): \((.*)\), line:(\d+):(\d+), endln:(\d+):(\d+)$')
# An indexed STEP: the decompiled text is a (possibly dotted) path ending in
# exactly one [...] group.
#
# THE DOT MUST BE ALLOWED, and a first cut of this census that forbade it
# UNDER-COUNTED THE POPULATION BY EIGHT CELLS.  A step's printed text is its
# vpiFullName, and golden's fullname is the CUMULATIVE dotted path: a BASE step
# prints `arb_sequence_q[i]` but a MIDDLE step prints `qc.queue[i]`.  With the
# dot forbidden, golden's middle steps fell out of the population entirely
# while OUR flat `ref_obj (queue[i])` stayed in it -- so the eight SimpleUVM
# middle-step cells read as "RHS-only", i.e. as noise, instead of as
# disagreements.  They are cells 48..55 of this law.
STEP = re.compile(r'^[A-Za-z_$][A-Za-z0-9_$]*(\.[A-Za-z_$][A-Za-z0-9_$]*)*'
                  r'\[[^\[\]]*\]$')


def scan(path):
    """Return {key: record} for every indexed single-component step whose
    printed vpiParent is a hier_path."""
    rows = defaultdict(lambda: {'kinds': set(), 'ends': set(), 'index': False,
                                'hp': set(), 'idxkind': set()})
    with open(path, errors='replace') as f:
        lines = f.readlines()
    n = len(lines)
    for i, ln in enumerate(lines):
        m = OBJ.match(ln.rstrip('\n'))
        if not m:
            continue
        indent, kind, text, sl, sc, el, ec = m.groups()
        if not STEP.match(text):
            continue
        # the element's own fields are printed at indent+2 as `|vpiXxx:`;
        # a nested object under such a field is at indent+2 as `\_kind:`.
        base = len(indent)
        parent_is_hp = False
        hp_name = None
        has_index = False
        idxkind = None
        j = i + 1
        cur_field = None
        while j < n:
            s = lines[j].rstrip('\n')
            stripped = s.lstrip()
            ind = len(s) - len(stripped)
            if ind <= base and stripped.startswith('\\_'):
                break            # next sibling object
            if ind < base:
                break
            if stripped.startswith('|'):
                if ind == base + 2:
                    cur_field = stripped[1:].split(':')[0]
                    if cur_field == 'vpiIndex':
                        has_index = True
            elif stripped.startswith('\\_') and ind == base + 2:
                mm = OBJ.match(s)
                if mm and cur_field == 'vpiParent' and mm.group(2) == 'hier_path':
                    parent_is_hp = True
                    hp_name = mm.group(3)
                if mm and cur_field == 'vpiIndex':
                    idxkind = mm.group(2)
            j += 1
        if not parent_is_hp:
            continue
        key = (text, int(sl), int(sc))
        r = rows[key]
        r['kinds'].add(kind)
        r['ends'].add((int(el), int(ec)))
        r['index'] = r['index'] or has_index
        if hp_name:
            r['hp'].add(hp_name)
        if idxkind:
            r['idxkind'].add(idxkind)
    return rows


def shape(r):
    return ('|'.join(sorted(r['kinds'])),
            'idx=%d' % (1 if r['index'] else 0),
            'endcol=' + ','.join(str(c) for _, c in sorted(r['ends'])))


def main():
    g, o = sys.argv[1], sys.argv[2]
    want_diff = '--diff' in sys.argv
    want_list = '--list' in sys.argv
    G, O = scan(g), scan(o)
    ks, kg, ko = set(G) & set(O), set(G) - set(O), set(O) - set(G)
    print('LHS(golden) indexed hier_path steps=%d  RHS(ours)=%d' % (len(G), len(O)))
    print('shared=%d  LHS-only=%d  RHS-only=%d' % (len(ks), len(kg), len(ko)))
    dis = [k for k in ks if shape(G[k]) != shape(O[k])]
    print('---- DISAGREEING SHARED KEYS: %d' % len(dis))
    tally = defaultdict(int)
    for k in dis:
        tally[(shape(G[k]), shape(O[k]))] += 1
    for (a, b), n in sorted(tally.items(), key=lambda x: -x[1]):
        print('  %4d   LHS %-34s   RHS %s' % (n, a, b))
    print('---- AGREEING SHARED KEYS by shape')
    ag = defaultdict(int)
    for k in ks:
        if shape(G[k]) == shape(O[k]):
            ag[shape(G[k])] += 1
    for a, n in sorted(ag.items(), key=lambda x: -x[1]):
        print('  %4d   %s' % (n, a))
    if kg:
        print('---- LHS-ONLY keys by golden shape')
        t = defaultdict(int)
        for k in kg:
            t[shape(G[k])] += 1
        for a, n in sorted(t.items(), key=lambda x: -x[1]):
            print('  %4d   %s' % (n, a))
    if ko:
        print('---- RHS-ONLY keys by our shape')
        t = defaultdict(int)
        for k in ko:
            t[shape(O[k])] += 1
        for a, n in sorted(t.items(), key=lambda x: -x[1]):
            print('  %4d   %s' % (n, a))
    if want_diff:
        print('---- every disagreeing key')
        for k in sorted(dis, key=lambda x: (x[1], x[2], x[0])):
            print('  %-40s @%d:%d   LHS %s   RHS %s   hp=%s' %
                  (k[0], k[1], k[2], shape(G[k]), shape(O[k]),
                   ';'.join(sorted(G[k]['hp']))[:60]))
    if '--only' in sys.argv:
        # The shared-key table can only speak about steps BOTH sides printed at
        # the same (text, start).  A step existing on ONE side alone is
        # invisible there, and invisible is exactly how a created-or-destroyed
        # object hides.  Run this BEFORE and AFTER: the two lists must be
        # IDENTICAL, because this law changes an object's KIND and its END
        # column, never its existence and never its start.
        print('---- LHS-ONLY keys, listed')
        for k in sorted(kg, key=lambda x: (x[1], x[2], x[0])):
            print('  L %-40s @%d:%d   %s' % (k[0], k[1], k[2], shape(G[k])))
        print('---- RHS-ONLY keys, listed')
        for k in sorted(ko, key=lambda x: (x[1], x[2], x[0])):
            print('  R %-40s @%d:%d   %s' % (k[0], k[1], k[2], shape(O[k])))
    if want_list:
        print('---- every shared key')
        for k in sorted(ks, key=lambda x: (x[1], x[2], x[0])):
            print('  %-40s @%d:%d   LHS %s   RHS %s' %
                  (k[0], k[1], k[2], shape(G[k]), shape(O[k])))


main()
