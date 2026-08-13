#!/usr/bin/env python3
"""r10earl42 census — CONCAT / ASSIGNMENT-PATTERN OPERAND ORDER and the
vpiReordered flag, BOTH SIDES, SPAN-KEYED, SECTION-SEPARATED.

LHS is ALWAYS golden (Surelog).  RHS is ALWAYS ours.

    usage: census42.py <g.dump> <o.dump>

Both dumps must already have uhdm-dump's first line (the database path)
stripped (`sed 1d`).

WHAT IT READS.  uhdm-dump prints an object header at some indent, then its
FIELDS at indent+2, and each field's CHILD OBJECTS also at indent+2 on the line
following the field name.  `|vpiParent:` is a BACK-reference printed in exactly
the same shape as a child, so the parser must not treat it as containment — it
is skipped by name.  Sections are the `|uhdm<x>:` lines at indent 0.

WHAT IT REPORTS.
  Q1  the design-wide vpiReordered population, per section, per side.
  Q2  every concat/pattern operation, keyed by (section, scope, op span),
      with its operand SPAN SEQUENCE classified ASC (source order) /
      DESC (reversed) / MIXED / SINGLE, joined golden-to-ours on that key.
  Q3  the join tallied: cells where we agree, cells where we are DESC and
      golden is ASC (the defect population), and the reverse.
"""
import re
import sys
from collections import defaultdict

OBJ = re.compile(r'^( *)(?:\\_)?([a-z_0-9]+): (.*)$')
FLD = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
# vpiConcatOp=33, vpiMultiConcatOp=34, vpiAssignmentPatternOp=75,
# vpiMultiAssignmentPatternOp=76 (sv_vpi_user.h - CHECKED, not guessed: an
# earlier draft of this script used 94/95 and SILENTLY MISSED every pattern)
PATTERNISH = {'33', '34', '75', '76'}


def parse(path):
    """Yield concat/pattern operation records and the reordered tally."""
    section = None
    # stack of [indent, kind, span, name, pending_field]
    stack = []
    ops = {}          # key -> record
    reordered = defaultdict(int)
    scopestack = []   # (indent, name)

    def close_to(ind):
        while stack and stack[-1][0] >= ind:
            fin = stack.pop()
            if fin[5] is not None:
                rec = fin[5]
                ops[rec['key']] = rec
        while scopestack and scopestack[-1][0] >= ind:
            scopestack.pop()

    with open(path, errors='replace') as fh:
        for raw in fh:
            line = raw.rstrip('\n')
            if not line:
                continue
            if line.startswith('|uhdm') and line.endswith(':'):
                section = line[5:-1]
                close_to(0)
                continue
            m = FLD.match(line)
            if m:
                ind, name, val = len(m.group(1)), m.group(2), m.group(3)
                close_to(ind)          # fields live at owner_indent+2
                if not stack:
                    continue
                owner = stack[-1]
                owner[4] = name        # pending field name
                if name == 'vpiReordered':
                    reordered[(section, owner[1])] += 1
                    if owner[5] is not None:
                        owner[5]['reordered'] = True
                if name == 'vpiOpType' and owner[1] == 'operation':
                    ot = val.strip()
                    if ot in PATTERNISH:
                        scope = scopestack[-1][1] if scopestack else '?'
                        owner[5] = {
                            'key': (section, scope, owner[2]),
                            'optype': ot,
                            'operands': [],
                            'reordered': False,
                        }
                continue
            m = OBJ.match(line)
            if m:
                ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
                close_to(ind)
                parent = stack[-1] if stack else None
                pfield = parent[4] if parent else None
                if pfield == 'vpiParent':
                    continue           # BACK-reference, not containment
                sm = SPAN.search(rest)
                span = ('%s:%s-%s:%s' % sm.groups()) if sm else '?'
                nm = rest.split(',')[0].strip()
                if parent is not None and parent[5] is not None \
                        and pfield == 'vpiOperand':
                    parent[5]['operands'].append((kind, span))
                stack.append([ind, kind, span, nm, None, None])
                if kind in ('module_inst', 'package', 'interface_inst'):
                    scopestack.append((ind, nm))
    close_to(-1)
    return ops, reordered


def classify(operands):
    if len(operands) <= 1:
        return 'SINGLE'
    keys = []
    for _, sp in operands:
        try:
            a, b = sp.split('-')[0].split(':')
            keys.append((int(a), int(b)))
        except Exception:
            return 'NOSPAN'
    if all(keys[i] < keys[i + 1] for i in range(len(keys) - 1)):
        return 'ASC'
    if all(keys[i] > keys[i + 1] for i in range(len(keys) - 1)):
        return 'DESC'
    return 'MIXED'


def main():
    g, o = sys.argv[1], sys.argv[2]
    gops, grd = parse(g)
    oops, ord_ = parse(o)

    print('Q1  vpiReordered population, per section (LHS golden / RHS ours)')
    secs = sorted({k for k in list(grd) + list(ord_)})
    if not secs:
        print('    (none on either side)')
    for k in secs:
        print('    %-30s %-12s golden %4d   ours %4d'
              % (k[0], k[1], grd.get(k, 0), ord_.get(k, 0)))
    print('    TOTAL   golden %d   ours %d' % (sum(grd.values()), sum(ord_.values())))

    print()
    print('Q2  concat/pattern operand ORDER, tallied per side')
    for label, ops in (('golden', gops), ('ours', oops)):
        t = defaultdict(int)
        for r in ops.values():
            t[(r['optype'], classify(r['operands']), r['reordered'])] += 1
        print('  %s: %d ops' % (label, len(ops)))
        for k in sorted(t):
            print('    optype %-3s order %-6s reordered=%-5s  %d'
                  % (k[0], k[1], k[2], t[k]))

    print()
    print('Q3  SPAN-KEYED JOIN (section, scope, op span)')
    both = set(gops) & set(oops)
    gonly = set(gops) - set(oops)
    oonly = set(oops) - set(gops)
    print('    keys: golden %d  ours %d  common %d  golden-only %d  ours-only %d'
          % (len(gops), len(oops), len(both), len(gonly), len(oonly)))
    t = defaultdict(int)
    diffs = []
    for k in both:
        gc, oc = classify(gops[k]['operands']), classify(oops[k]['operands'])
        gf, of = gops[k]['reordered'], oops[k]['reordered']
        t[(gc, oc, gf, of)] += 1
        if gc != oc or gf != of:
            diffs.append((k, gc, oc, gf, of))
    for k in sorted(t):
        print('    golden %-6s -> ours %-6s   flag g=%-5s o=%-5s   %d'
              % (k[0], k[1], k[2], k[3], t[k]))
    print()
    print('    DIVERGENT CELLS (%d):' % len(diffs))
    for d in sorted(diffs)[:60]:
        print('      %-14s %-46s %-22s golden %s/%s -> ours %s/%s'
              % (d[0][0], d[0][1], d[0][2], d[1], d[3], d[2], d[4]))


main()
