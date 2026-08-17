#!/usr/bin/env python3
"""r10earl56 VERIFIER — v56span3.py, THE DEEP (BELOW-SLOT) 3-WAY CENSUS.

WHY IT EXISTS.  `census56.py` enumerates SELECT BOUND SLOTS and reads each
slot's DIRECT child, so a reference NESTED inside a bound OPERATION is invisible
to it -- the slot reads `operation` on both sides whatever happens below.  That
is not a theoretical gap: `vctl56.sh` rebuilds this pass's own broken first
build and MEASURES `census56.py` reporting `UNMOVED-GOOD=30404 AWAY-GOLDEN=0`
for a binary with 107 pristine-right cells destroyed, i.e. numbers IDENTICAL to
the clean build.  This instrument reports AWAY-GOLDEN=107 for the same pair.

WHAT IT KEYS ON.  EVERY object in the dump, at any depth, under any parent kind:
  key   = (VIEW, own line:col, the |vpiSlot: label, parent kind, parent span,
           occurrence)
  value = kind + last name component + vpiDecompile/vpiSize/value-line/
          vpiName/vpiDirection/vpiOpType/... i.e. the IDENTITY, not the kind.
A span key (not a structural path) because golden has objects we lack and vice
versa, and a path key shifts every sibling index below the first difference.
Fullname and span are NOT compared as fields (the standing measurement law).

THREE PARSER RULES, each one a defect this instrument had and a wrong number it
produced before the rule existed:
  * SLOT INDENT is `<=` the object's, not `<`.  With `<` every slot read `?`,
    which merged unrelated slots.
  * OWNERSHIP: an object is a real child only when its header line is
    IMMEDIATELY preceded by its `|vpiSlot:` label.  A header preceded by another
    header is a BACK-REFERENCE re-print (a ref_typespec re-prints its owning
    constant, unlabelled).  Keying those manufactured 2 phantom AWAY-GOLDEN rows
    on v5_shadow56 and 3 on v2_nestedsel56 -- every one with an EMPTY payload.
  * IDENTITY payload, not kind.  Kind-only comparison reported an AWAY-GOLDEN on
    v5_shadow56 that was false: golden's `constant` there holds UINT:5 (Surelog
    resolves the shadowed name to the OUTER declaration) and the pristine
    binary's holds UINT:3, so "pristine agreed with golden" was never true.

NODEDUP=1 keys every printed object, including uhdm-dump's abbreviated
re-prints; unset, an abbreviated re-print of an already-seen (view,span,kind) is
dropped.  NODEDUP=1 reproduces this pass's own arm counts (a1..a5 = 8/8/6/8/6);
the deduped counts are 4/4/3/4/3.  BOTH were run and both give AWAY-GOLDEN=0.

CALIBRATION CONTRACT: run <x> <x> <x> first -- everything must land in
UNMOVED-GOOD with TO/AWAY/STILL = 0, or the instrument is broken.  Measured on
Earlgrey_0_1: golden/golden/golden agrees on 909 396 objects, 0 disagreements.

  usage: v56span3.py <golden> <pristine> <patched> [--all]
         v56span3.py <a> <b> [--all]          two-way
"""
import re, sys, collections, os

HDR = re.compile(r'^(\s*)\\_([a-z_0-9]+): *(.*)$')
SLOT = re.compile(r'^(\s*)\|(vpi[A-Za-z0-9_]+|uhdm[A-Za-z0-9_]+):\s*$')
SCAL = re.compile(r'^(\s*)\|([A-Za-z0-9_]+):(.*)$')
KEEP = ('vpiDecompile', 'vpiSize', 'vpiConstType', 'vpiName', 'vpiDirection',
        'UINT', 'INT', 'HEX', 'BIN', 'OCT', 'STRING', 'REAL', 'SCAL',
        'vpiIndexedPartSelectType', 'vpiConstantSelect', 'vpiOpType')

def parse(path):
    lines = open(path, errors='replace').read().split('\n')
    out = {}
    stack = []
    view = None
    cur_slot, slot_indent = None, -1
    prev_was_slot = False
    occ = collections.Counter()
    seen = set()
    for i, line in enumerate(lines):
        s = line.strip()
        if s == '|uhdmtopModules:':
            view, stack, cur_slot, slot_indent = 'ELAB', [], 'topModules', 0
            prev_was_slot = True
            continue
        if s == '|uhdmallModules:':
            view, stack, cur_slot, slot_indent = 'DEF', [], 'allModules', 0
            prev_was_slot = True
            continue
        if view is None:
            continue
        m = SLOT.match(line)
        if m:
            cur_slot, slot_indent = m.group(2), len(m.group(1))
            prev_was_slot = True
            continue
        m = HDR.match(line)
        if not m:
            if line.strip():
                prev_was_slot = False
            continue
        owned = prev_was_slot
        prev_was_slot = False
        # OWNERSHIP RULE (v3 of this instrument): in uhdm-dump an object is a
        # real child ONLY when its header line is IMMEDIATELY preceded by its
        # `|vpiSlot:` label.  A header preceded by ANOTHER header is a
        # BACK-REFERENCE re-print (a ref_typespec re-prints its owning
        # constant, unlabelled).  v2 keyed those and manufactured two
        # AWAY-GOLDEN phantoms on v5_shadow56 and three on v2_nestedsel56 --
        # every one with an EMPTY payload, which is the tell.
        if not owned:
            continue
        ind, kind, rest = len(m.group(1)), m.group(2), m.group(3)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        slot = cur_slot if (cur_slot is not None and slot_indent <= ind) else '?'
        if slot == 'vpiParent':
            continue
        msp = re.search(r'line:(\d+):(\d+)', rest)
        sp = '%s:%s' % (msp.group(1), msp.group(2)) if msp else '-'
        pk, psp = (stack[-1][1], stack[-1][2]) if stack else ('root', '-')
        nm = ''
        mm = re.search(r'\((.*?)\)', rest)
        if mm:
            nm = mm.group(1).split('.')[-1]
        # scalar fields printed as DIRECT children (indent ind+2)
        pay = []
        for j in range(i + 1, min(i + 24, len(lines))):
            l2 = lines[j]
            if not l2.strip():
                continue
            ind2 = len(l2) - len(l2.lstrip(' '))
            if ind2 <= ind:
                break
            if ind2 != ind + 2:
                continue
            m2 = SCAL.match(l2)
            if not m2:
                continue
            if m2.group(3) == '' :
                continue
            if m2.group(2) in KEEP:
                pay.append('%s=%s' % (m2.group(2), m2.group(3).strip()))
        # RE-VISIT RULE: uhdm-dump prints an ALREADY-VISITED object as a bare
        # header with NO scalar children.  Those are not cells; they are second
        # sightings of a cell already keyed (the ELAB listing holds each
        # gen-scope assign twice).  Keying them made v5_shadow56 report two
        # extra AWAY-GOLDEN rows that are the SAME two objects it already
        # reported as STILL-WRONG -- and the empty payload was the only tell.
        if os.environ.get("NODEDUP") != "1" and not pay and (view, sp, kind) in seen:
            stack.append((ind, kind, sp))
            continue
        seen.add((view, sp, kind))
        key = (view, sp, slot, pk, psp)
        occ[key] += 1
        out[key + (occ[key],)] = '%s(%s)[%s]' % (kind, nm, ','.join(pay))
        stack.append((ind, kind, sp))
    return out

def fmt(k):
    return '%-4s %-9s %-16s par=%-22s %-9s occ=%d' % (k[0], k[1], k[2], k[3], k[4], k[5])

def main():
    args = [x for x in sys.argv[1:] if not x.startswith('--')]
    allf = '--all' in sys.argv
    if len(args) == 2:
        a, b = parse(args[0]), parse(args[1])
        tal = collections.Counter()
        for k in sorted(set(list(a) + list(b))):
            va, vb = a.get(k), b.get(k)
            t = 'agree' if va == vb else ('ONLY-A' if vb is None else
                 ('ONLY-B' if va is None else 'DISAGREE'))
            tal[t] += 1
            if t == 'DISAGREE' or (allf and t != 'agree'):
                print('%-9s %s A=%s B=%s' % (t, fmt(k), va, vb))
        print('-- ' + ' '.join('%s=%d' % (x, tal[x]) for x in
              ('agree', 'DISAGREE', 'ONLY-A', 'ONLY-B')))
        return
    g, p, q = (parse(x) for x in args[:3])
    tal = collections.Counter()
    for k in sorted(set(list(g) + list(p) + list(q))):
        gv, pv, qv = g.get(k), p.get(k), q.get(k)
        if pv is None or qv is None:
            if pv != qv:
                tal['KEY-MOVED'] += 1
                print('KEY-MOVED   %s gold=%s pris=%s pat=%s' % (fmt(k), gv, pv, qv))
            else:
                tal['KEY-ONLY-GOLD'] += 1
            continue
        if pv == qv:
            tal['UNMOVED-GOOD' if pv == gv else 'UNMOVED-BAD'] += 1
            if pv != gv and allf:
                print('UNMOVED-BAD %s gold=%s ours=%s' % (fmt(k), gv, pv))
            continue
        if qv == gv:
            tal['TO-GOLDEN'] += 1
            print('TO-GOLDEN   %s gold=%s pris=%s pat=%s' % (fmt(k), gv, pv, qv))
        elif pv == gv:
            tal['AWAY-GOLDEN'] += 1
            print('AWAY-GOLDEN %s gold=%s pris=%s pat=%s' % (fmt(k), gv, pv, qv))
        else:
            tal['STILL-WRONG'] += 1
            print('STILL-WRONG %s gold=%s pris=%s pat=%s' % (fmt(k), gv, pv, qv))
    print('== ' + ' '.join('%s=%d' % (x, tal[x]) for x in
          ('UNMOVED-GOOD', 'TO-GOLDEN', 'AWAY-GOLDEN', 'STILL-WRONG',
           'UNMOVED-BAD', 'KEY-MOVED', 'KEY-ONLY-GOLD')))

main()
