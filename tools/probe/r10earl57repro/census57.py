#!/usr/bin/env python3
"""r10earl57 — THE CAST-TYPESPEC CENSUS.

Keys EVERY `vpiOpType:67` (vpiCastOp) operation in a uhdm-dump listing on

    (the cast operation's own line:col, the scope FULLNAME its ref_typespec
     carries, the occurrence index of that pair)

and records what the cast's TARGET TYPESPEC is: its KIND, its VpiName, its
span, and whether it carries a vpiExpr (`Cast_to_expr`) — the three fields
`typespec::Compare` and `int_typespec::Compare` actually read.

WHY THE KEY LOOKS LIKE THAT (earl56's two instrument corrections, re-applied):
  * uhdm-dump prints a subtree ONCE per parent that lists it, so the SAME
    object appears many times; the occurrence index keeps the two sides
    lined up instead of merging them.
  * The ELAB listing holds each gen-scope assign TWICE (an instance-scoped
    copy and a flat one).  The ref_typespec's fullname is what tells them
    apart, so it is part of the key, not a payload.
  * Keying on the cast op's line:col ALONE merges the 127 elaborated copies
    of one gen block into one chain; the fullname splits them.

CALIBRATION IS MANDATORY: run it golden-vs-golden first.  A detector that
flags everything is a broken detector.

  usage:  census57.py <a.dump> <b.dump>            # two-way (A=golden)
          census57.py --list <a.dump>              # dump the table
          census57.py --attrib <g> <pris> <pat>    # three-way join
"""
import re, sys, collections

OP_RE = re.compile(r'^(\s*)\\_operation: , line:(\d+):(\d+), endln:(\d+):(\d+)\s*$')
TS_RE = re.compile(r'^\s*\\_([a-z_]*typespec): (?:\(([^)]*)\))?,? ?(?:line:(\d+):(\d+), endln:(\d+):(\d+))?')
RT_RE = re.compile(r'^\s*\\_ref_typespec: (?:\(([^)]*)\))?')

def indent(l):
    return len(l) - len(l.lstrip(' '))

def parse(path):
    """-> list of (key, payload) in file order."""
    lines = open(path, errors='replace').read().split('\n')
    out = []
    n = len(lines)
    for i, l in enumerate(lines):
        m = OP_RE.match(l)
        if not m:
            continue
        ind = len(m.group(1))
        opl, opc = int(m.group(2)), int(m.group(3))
        # Scan this operation's own field block (indent == ind+2 for `|field:`)
        j = i + 1
        is_cast = False
        scope = None
        tskind = tsname = tsspan = None
        has_expr = False
        while j < n:
            lj = lines[j]
            if not lj.strip():
                j += 1
                continue
            ij = indent(lj)
            if ij <= ind and not lj.lstrip().startswith('|'):
                break
            if ij == ind + 2 and lj.lstrip().startswith('|'):
                f = lj.strip()
                if f == '|vpiOpType:67':
                    is_cast = True
                elif f == '|vpiTypespec:':
                    # next line is the ref_typespec
                    if j + 1 < n:
                        rm = RT_RE.match(lines[j + 1])
                        if rm:
                            scope = rm.group(1) or ''
                            # find |vpiActual: inside it
                            k = j + 2
                            rind = indent(lines[j + 1])
                            while k < n:
                                lk = lines[k]
                                if not lk.strip():
                                    k += 1
                                    continue
                                ik = indent(lk)
                                if ik <= rind and not lk.lstrip().startswith('|'):
                                    break
                                if ik == rind + 2 and lk.strip() == '|vpiActual:':
                                    tm = TS_RE.match(lines[k + 1]) if k + 1 < n else None
                                    if tm:
                                        tskind = tm.group(1)
                                        tsname = tm.group(2) or ''
                                        tsspan = ('%s:%s-%s:%s' % (tm.group(3), tm.group(4),
                                                                   tm.group(5), tm.group(6))
                                                  if tm.group(3) else ':')
                                        # does the actual carry a vpiExpr?
                                        aind = indent(lines[k + 1])
                                        q = k + 2
                                        while q < n:
                                            lq = lines[q]
                                            if not lq.strip():
                                                q += 1
                                                continue
                                            iq = indent(lq)
                                            if iq <= aind and not lq.lstrip().startswith('|'):
                                                break
                                            if iq == aind + 2 and lq.strip() == '|vpiExpr:':
                                                has_expr = True
                                            q += 1
                                    break
                                k += 1
            if ij <= ind and lj.lstrip().startswith('|'):
                break
            j += 1
        if not is_cast:
            continue
        out.append((('%d:%d' % (opl, opc), scope if scope is not None else '?'),
                    (tskind or '<none>', tsname or '', tsspan or ':', has_expr)))
    return out

def keyed(path):
    seq = parse(path)
    cnt = collections.Counter()
    d = {}
    for k, p in seq:
        cnt[k] += 1
        d[(k[0], k[1], cnt[k])] = p
    return d

def fmt(p):
    if p is None:
        return 'None'
    return '%s(%s)@%s%s' % (p[0], p[1], p[2], ' +expr' if p[3] else '')

def main():
    a = sys.argv[1:]
    if a[0] == '--list':
        d = keyed(a[1])
        for k in sorted(d, key=lambda x: (int(x[0].split(':')[0]), int(x[0].split(':')[1]), x[1], x[2])):
            print('%-12s %-4d %-60s %s' % (k[0], k[2], k[1][-60:], fmt(d[k])))
        print('TOTAL casts=%d' % len(d))
        return
    if a[0] == '--attrib':
        g, pr, pa = keyed(a[1]), keyed(a[2]), keyed(a[3])
        o = collections.Counter()
        rows = collections.defaultdict(list)
        for k in set(g) | set(pr) | set(pa):
            if k not in g or k not in pr or k not in pa:
                o['KEY-ONLY-ONE-SIDE'] += 1
                continue
            gp, rp, ap = g[k], pr[k], pa[k]
            pr_ok, pa_ok = rp == gp, ap == gp
            if pr_ok and pa_ok:
                o['UNMOVED-GOOD'] += 1
            elif not pr_ok and pa_ok:
                o['TO-GOLDEN'] += 1; rows['TO-GOLDEN'].append((k, gp, rp, ap))
            elif pr_ok and not pa_ok:
                o['AWAY-GOLDEN'] += 1; rows['AWAY-GOLDEN'].append((k, gp, rp, ap))
            elif rp == ap:
                o['UNMOVED-BAD'] += 1; rows['UNMOVED-BAD'].append((k, gp, rp, ap))
            else:
                o['STILL-WRONG'] += 1; rows['STILL-WRONG'].append((k, gp, rp, ap))
        for cl in ('UNMOVED-GOOD', 'TO-GOLDEN', 'AWAY-GOLDEN', 'STILL-WRONG',
                   'UNMOVED-BAD', 'KEY-ONLY-ONE-SIDE'):
            print('%-18s %d' % (cl, o[cl]))
        for cl in ('AWAY-GOLDEN', 'TO-GOLDEN', 'STILL-WRONG', 'UNMOVED-BAD'):
            for k, gp, rp, ap in rows[cl][:40]:
                print('  [%s] %s occ%d %s\n      G=%s\n      pris=%s\n      pat=%s'
                      % (cl, k[0], k[2], k[1][-70:], fmt(gp), fmt(rp), fmt(ap)))
        return
    g, o = keyed(a[0]), keyed(a[1])
    st = collections.Counter()
    shapes = collections.Counter()
    ex = collections.defaultdict(list)
    for k in set(g) | set(o):
        if k not in g:
            st['ONLY-OURS'] += 1; continue
        if k not in o:
            st['ONLY-GOLD'] += 1; continue
        if g[k] == o[k]:
            st['agree'] += 1
        else:
            st['DISAGREE'] += 1
            sh = '%s>%s' % (g[k][0], o[k][0])
            if g[k][0] == o[k][0]:
                sh += ' NAME:%s>%s' % (g[k][1] or '-', o[k][1] or '-')
                if g[k][3] != o[k][3]:
                    sh += ' EXPR:%d>%d' % (g[k][3], o[k][3])
            shapes[sh] += 1
            ex[sh].append((k, g[k], o[k]))
    for c in ('agree', 'DISAGREE', 'ONLY-GOLD', 'ONLY-OURS'):
        print('%-12s %d' % (c, st[c]))
    print('--- disagreement families ---')
    for sh, n in shapes.most_common(40):
        print('%6d  %s' % (n, sh))
        for k, gp, op in ex[sh][:3]:
            print('        %s occ%d %s' % (k[0], k[2], k[1][-70:]))
            print('           G=%s' % fmt(gp))
            print('           O=%s' % fmt(op))

main()
