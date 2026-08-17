#!/usr/bin/env python3
"""r10earl56 — the SELECT-BOUND census.

Every `bit_select`, `part_select`, `indexed_part_select` and `var_select` in a
uhdm-dump, keyed on (VIEW, the select's OWN vpiFullName, its line:col span,
slot, occurrence), with the KIND of each bound slot as the value.  Golden vs
ours; `--all` prints agreements too.

WHY THIS KEY.  The law under test decides ONE slot of ONE select
(`ref_obj` vs `constant`), so the select is the unit.  The VIEW is part of the
key because the DEF (`uhdmallModules`) and ELAB (`uhdmtopModules`) listings hold
selects at the SAME span for the SAME signal and merging them would hide the
earl38 DEF fence.  The OCCURRENCE index is part of the key because the ELAB
listing holds each gen-scope assign TWICE (an instance-scoped copy and a flat
one) -- merging those reported the wrong copy's answer for the other and had to
be fixed before any number here was believed.

  usage: census56.py <golden.dump> [<ours.dump>] [--all]
         census56.py <golden> <pristine> <patched> --attrib
"""
import re, sys, collections

SLOTS = ("vpiBaseExpr", "vpiWidthExpr", "vpiLeftRange", "vpiRightRange",
         "vpiIndex")
SELS = ("bit_select", "part_select", "indexed_part_select", "var_select")
HDR = re.compile(r'\\_(%s):' % '|'.join(SELS))
# The header line is `\_kind: name (work@...), line:L:C, endln:L2:C2`.  The span
# must be pulled with its OWN search: folding it into the header regex as an
# optional trailing group let the non-greedy name group swallow it and every key
# came out `?:?`, which silently merged every select on the same signal into one
# occurrence chain -- a2 then reported a bit_select disagreement that does not
# exist.  A key that cannot tell two objects apart is not a key.
SPAN = re.compile(r', line:(\d+):(\d+)')

def parse(path):
    view = None
    out = {}
    occ = {}
    lines = open(path, errors='replace').read().split('\n')
    n = len(lines)
    for i, l in enumerate(lines):
        s = l.strip()
        if s == '|uhdmtopModules:':
            view = 'ELAB'
            continue
        if s == '|uhdmallModules:':
            view = 'DEF'
            continue
        m = HDR.match(s)
        if not m:
            continue
        kind = m.group(1)
        sm2 = SPAN.search(s)
        ln, col = (sm2.group(1), sm2.group(2)) if sm2 else (None, None)
        base = len(l) - len(l.lstrip(' '))
        # the block: following lines with a strictly greater indent
        j = i + 1
        blk = []
        while j < n and (lines[j].strip() == '' or
                         len(lines[j]) - len(lines[j].lstrip(' ')) > base):
            blk.append(lines[j].strip())
            j += 1
        full = ''
        for b in blk:
            mm = re.match(r'\|vpiFullName:(.*)$', b)
            if mm:
                full = mm.group(1).strip()
                break
        span = '%s:%s' % (ln or '?', col or '?')
        idk = (view, kind, full, span)
        occ[idk] = occ.get(idk, 0) + 1
        # DIRECT children only: a nested select's own slots must not be
        # attributed to the outer one.  A slot line is a DIRECT child when its
        # indent is base+2 (the dump indents by two per level).
        raw = []
        j2 = i + 1
        while j2 < n and (lines[j2].strip() == '' or
                          len(lines[j2]) - len(lines[j2].lstrip(' ')) > base):
            raw.append(lines[j2])
            j2 += 1
        cnt = collections.Counter()
        for k, b in enumerate(raw):
            if len(b) - len(b.lstrip(' ')) != base + 2:
                continue
            sb = b.strip()
            if not (sb.startswith('|') and sb.endswith(':')):
                continue
            sl = sb[1:-1]
            if sl not in SLOTS:
                continue
            ck = det = ''
            if k + 1 < len(raw):
                mm = re.match(r'\\_([a-z_0-9]+):', raw[k+1].strip())
                if mm:
                    ck = mm.group(1)
            if ck == 'ref_obj':
                for b2 in raw[k+1:k+9]:
                    mm = re.match(r'\|vpiName:(.*)$', b2.strip())
                    if mm:
                        det = mm.group(1).strip()
                        break
            cnt[sl] += 1
            out[idk + ('%s#%d' % (sl, cnt[sl]), occ[idk])] = \
                ck + ('(' + det + ')' if det else '')
    return out

def cmp2(a, b, showall):
    keys = list(a.keys()) + [k for k in b if k not in a]
    tal = collections.Counter()
    rows = []
    for k in keys:
        va, vb = a.get(k), b.get(k)
        if va is None:
            t = 'ONLY-OURS'
        elif vb is None:
            t = 'ONLY-GOLD'
        elif va == vb:
            t = 'agree'
        else:
            t = 'DISAGREE'
        tal[t] += 1
        if t != 'agree' or showall:
            rows.append((t, k, va, vb))
    for t, k, va, vb in rows:
        print('%-9s %-4s %-20s %-64s %-8s %-14s occ=%d G=%-22s O=%s' %
              (t, k[0], k[1], k[2][:64], k[3], k[4], k[5], str(va), str(vb)))
    print('-- ' + ' '.join('%s=%d' % (x, tal[x]) for x in
                           ('agree', 'DISAGREE', 'ONLY-GOLD', 'ONLY-OURS')))
    return tal

def main():
    args = [x for x in sys.argv[1:] if not x.startswith('--')]
    flags = [x for x in sys.argv[1:] if x.startswith('--')]
    if '--attrib' in flags:
        g, p1, p2 = (parse(x) for x in args[:3])
        tal = collections.Counter()
        for k in set(list(g) + list(p1) + list(p2)):
            gv, av, bv = g.get(k), p1.get(k), p2.get(k)
            if av is None or bv is None:
                tal['KEY-ONLY-ONE-SIDE'] += 1
                print('KEY-ONLY %s pris=%s pat=%s gold=%s' % (k, av, bv, gv))
                continue
            if av == bv:
                tal['UNMOVED-GOOD' if av == gv else 'UNMOVED-BAD'] += 1
                if av != gv and '--all' in flags:
                    print('UNMOVED-BAD %s G=%s O=%s' % (k, gv, av))
                continue
            if bv == gv:
                tal['TO-GOLDEN'] += 1
                print('TO-GOLDEN   %s G=%s pris=%s pat=%s' % (k, gv, av, bv))
            elif av == gv:
                tal['AWAY-GOLDEN'] += 1
                print('AWAY-GOLDEN %s G=%s pris=%s pat=%s' % (k, gv, av, bv))
            else:
                tal['STILL-WRONG'] += 1
                print('STILL-WRONG %s G=%s pris=%s pat=%s' % (k, gv, av, bv))
        print('== ' + ' '.join('%s=%d' % (x, tal[x]) for x in
              ('UNMOVED-GOOD', 'TO-GOLDEN', 'AWAY-GOLDEN', 'STILL-WRONG',
               'UNMOVED-BAD', 'KEY-ONLY-ONE-SIDE')))
        return
    a = parse(args[0])
    if len(args) == 1:
        for k, v in sorted(a.items()):
            print('%-4s %-20s %-64s %-8s %-14s occ=%d %s' %
                  (k[0], k[1], k[2][:64], k[3], k[4], k[5], v))
        print('-- slots=%d' % len(a))
        return
    cmp2(a, parse(args[1]), '--all' in flags)

main()
