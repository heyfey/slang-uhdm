#!/usr/bin/env python3
"""r10uvm67 — THE GRID: every RANGE-BOUND reference, cell for cell.

  usage: ct67cells.py <g.dump> <o.dump> [--all]

TABLE A — every `ref_obj` that is a RANGE BOUND (`vpiLeftRange` / `vpiRightRange`
of a `range`, or an operand of an operation that is one), keyed by
(vpiName, span, the FULLNAME SHAPE) and carrying the `vpiActual` KIND on each
side.  A cell is SAME only when both sides agree on the actual's kind AND span.

TABLE B — the same references keyed WITHOUT the fullname, so a fullname-only
disagreement (`f::f.N` vs `f::f::N`) shows up as its own row instead of
silently splitting a cell into two UNMEASURED halves.

TRAPS ENCODED, each paid for earlier in this campaign:
  * an OBJECT IS NOT A DUMP OCCURRENCE — a childless print is a back-reference
    and is dropped, never counted as a second cell;
  * a key present on ONE side only is `-NOOBJ-`/UNMEASURED and is NEVER counted
    as agreement;
  * `file:<workdir>` is stripped before any comparison (ARM-PATH DUMP EMBEDS
    file:<workdir>);
  * the ACTUAL is compared by KIND+SPAN, not by identity: the dump cannot show
    identity, and two views legitimately bind different objects at the same
    span (a folded `constant` vs the declaration's `operation`).
"""
import collections
import sys

from dumptree import parse, is_backref

VIEWKINDS = ('package', 'module_inst', 'class_defn', 'design', 'interface_inst')


def viewpath(n):
    out = []
    p = n.parent
    while p is not None:
        if p.kind in VIEWKINDS:
            out.append('%s(%s)' % (p.kind, p.name or ''))
        p = p.parent
    return '/'.join(reversed(out)) or '-TOP-'


def in_range(n):
    """True when this ref sits under a `range` (directly or through ops)."""
    p, d = n.parent, 0
    while p is not None and d < 5:
        if p.kind == 'range':
            return True
        if p.kind not in ('operation',):
            return False
        p, d = p.parent, d + 1
    return False


def actual(n):
    k = n.field_kids('vpiActual')
    if not k:
        return 'NULL'
    return '%s@%s' % (k[0].kind, k[0].span)


def collect(path):
    _r, nodes = parse(path)
    rows = []
    for n in nodes:
        if n.kind != 'ref_obj' or is_backref(n):
            continue
        if not in_range(n):
            continue
        full = n.fields.get('vpiFullName', '')
        rows.append({'name': n.fields.get('vpiName', n.name or ''),
                     'full': full, 'span': n.span, 'view': viewpath(n),
                     'act': actual(n), 'line': n.line})
    return rows


def table(gr, orr, key):
    gk = collections.defaultdict(list)
    ok = collections.defaultdict(list)
    for r in gr:
        gk[key(r)].append(r['act'])
    for r in orr:
        ok[key(r)].append(r['act'])
    same = diff = unm = 0
    rows = []
    for k in sorted(set(gk) | set(ok)):
        g = sorted(gk.get(k, []))
        o = sorted(ok.get(k, []))
        if not g or not o:
            st = 'UNMEASURED'
            unm += 1
        elif g == o:
            st = 'SAME'
            same += 1
        else:
            st = 'DIFF'
            diff += 1
        rows.append((st, k, g or ['-NOOBJ-'], o or ['-NOOBJ-']))
    return rows, same, diff, unm


def main():
    g, o = sys.argv[1], sys.argv[2]
    show_all = '--all' in sys.argv[3:]
    gr, orr = collect(g), collect(o)
    print('range-bound ref_obj OBJECT prints: golden=%d ours=%d' % (len(gr), len(orr)))
    for tag, key in (('TABLE A  key=(name, span, fullname)',
                      lambda r: (r['name'], r['span'], r['full'])),
                     ('TABLE B  key=(name, span)   [fullname-blind]',
                      lambda r: (r['name'], r['span']))):
        rows, same, diff, unm = table(gr, orr, key)
        print('\n== %s ==' % tag)
        for st, k, gv, ov in rows:
            if st == 'SAME' and not show_all:
                continue
            print('  %-10s %-58s G=%-46s O=%s'
                  % (st, str(k)[:58], ','.join(gv)[:46], ','.join(ov)))
        print('  --> SAME=%d DIFF=%d UNMEASURED=%d' % (same, diff, unm))


if __name__ == '__main__':
    main()
