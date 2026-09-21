#!/usr/bin/env python3
"""r11u78 TYPESPEC-AWARE SHAPE LISTER — the committed r11u76 `shape.py`
(DEC/TIME-aware value regex included, r11u76repro generation) with ONE
addition: every bare `constant` operand also prints its OWN `vpiTypespec`
chain, because `expr::Compare` READS `Typespec` and the committed lister
cannot see it.

A constant cell reads

    const/<vpiSize>@<vpiConstType>=<VALUE>/ts=<actual-kind>(<name>)<S|U>

where `ts=-` means the constant carries NO `vpiTypespec` at all, `<S>` marks
`|vpiSigned:1` on the actual typespec and `<U>` its absence.  Nothing else
about the lister moved; run it beside `shape.py` and the non-`ts` part of
every cell is character-identical.

usage: ts78.py <dump.txt> [<dump2.txt> ...]"""
import re, sys


def ind(l):
    return len(l) - len(l.lstrip())


def block(lines, i, base):
    out = []
    while i < len(lines):
        l = lines[i]
        if l.strip() and ind(l) <= base:
            break
        out.append(l)
        i += 1
    return out, i


def ts_of(sub, base):
    """`sub` is a constant's child block at indent `base`; return the
    vpiTypespec actual's kind(name) plus its signedness marker."""
    lab = None
    a = 0
    while a < len(sub):
        l = sub[a]
        if ind(l) != base:
            a += 1
            continue
        s = l.lstrip()
        if s.startswith('|'):
            lab = s.split(':', 1)[0]
            a += 1
            continue
        if s.startswith('\\_') and lab == '|vpiTypespec':
            rsub, _ = block(sub, a + 1, base)
            lab2 = None
            b = 0
            while b < len(rsub):
                l2 = rsub[b]
                if ind(l2) != base + 2:
                    b += 1
                    continue
                s2 = l2.lstrip()
                if s2.startswith('|'):
                    lab2 = s2.split(':', 1)[0]
                    b += 1
                    continue
                if s2.startswith('\\_') and lab2 == '|vpiActual':
                    mm = re.match(r'\\_(\w+): (\(([^)]*)\))?', s2)
                    asub, _ = block(rsub, b + 1, base + 2)
                    sg = 'U'
                    for l3 in asub:
                        if l3.lstrip().startswith('|vpiSigned:'):
                            sg = 'S' if l3.split(':', 1)[1].strip() == '1' \
                                else 'U'
                    return mm.group(1) + '(' + (mm.group(3) or '') + ')' + sg
                b += 1
            # a vpiTypespec whose actual we could not read
            mm = re.match(r'\\_(\w+):', s)
            return mm.group(1) + '(?)?'
        a += 1
    return '-'


def parse(path):
    lines = open(path, errors='replace').read().splitlines()
    sect = None
    out = []
    i = 0
    while i < len(lines):
        ln = lines[i]
        m = re.match(r'^\|(uhdm\w+):', ln)
        if m:
            sect = m.group(1)
            i += 1
            continue
        m = re.match(r'^(\s*)\\_param_assign: , (line:[\d:]+)', ln)
        if not m:
            i += 1
            continue
        pind = ind(ln)
        loc = m.group(2)
        blk, i = block(lines, i + 1, pind)
        name = '?'
        rhs_at = None
        label = None
        for a, l in enumerate(blk):
            if ind(l) != pind + 2:
                continue
            s = l.lstrip()
            if s.startswith('|'):
                label = s.split(':', 1)[0]
                continue
            if s.startswith('\\_') and label == '|vpiLhs':
                mm = re.search(r'\\_parameter: \(([^)]*)\)', s)
                if mm:
                    name = mm.group(1)
            if s.startswith('\\_') and label == '|vpiRhs':
                rhs_at = a
        if rhs_at is None or not blk[rhs_at].lstrip().startswith('\\_operation:'):
            out.append((sect, name, loc, 'RHS-NOT-OPERATION'))
            continue
        rind = ind(blk[rhs_at])
        rblk, _ = block(blk, rhs_at + 1, rind)
        ts = '-'
        op = '?'
        ops = []
        label = None
        a = 0
        while a < len(rblk):
            l = rblk[a]
            if ind(l) != rind + 2:
                a += 1
                continue
            s = l.lstrip()
            if s.startswith('|'):
                label = s.split(':', 1)[0]
                if label == '|vpiOpType':
                    op = s.split(':', 1)[1].strip()
                a += 1
                continue
            if s.startswith('\\_'):
                sub, _ = block(rblk, a + 1, rind + 2)
                kind = re.match(r'\\_(\w+):', s).group(1)
                if label == '|vpiTypespec':
                    lab2 = None
                    for l2 in sub:
                        if ind(l2) != rind + 4:
                            continue
                        s2 = l2.lstrip()
                        if s2.startswith('|'):
                            lab2 = s2.split(':', 1)[0]
                            continue
                        if s2.startswith('\\_') and lab2 == '|vpiActual':
                            mm = re.match(r'\\_(\w+): (\(([^)]*)\))?', s2)
                            ts = mm.group(1) + '(' + (mm.group(3) or '') + ')'
                            break
                elif label == '|vpiOperand':
                    if kind == 'constant':
                        sz = '?'
                        ct = '?'
                        val = ''
                        for l2 in sub:
                            s2 = l2.lstrip()
                            if s2.startswith('|vpiSize:'):
                                sz = s2.split(':', 1)[1].strip()
                            elif s2.startswith('|vpiConstType:'):
                                ct = s2.split(':', 1)[1].strip()
                            elif re.match(
                                r'\|(UINT|INT|DEC|BIN|HEX|OCT|STRING|REAL|'
                                r'SCALAR|TIME):', s2):
                                val = s2[1:].strip()
                        ops.append('const/%s@%s=%s/ts=%s'
                                   % (sz, ct, val, ts_of(sub, rind + 4)))
                    elif kind == 'operation':
                        ot = '?'
                        for l2 in sub:
                            if ind(l2) == rind + 4 and \
                                    l2.lstrip().startswith('|vpiOpType:'):
                                ot = l2.split(':', 1)[1].strip()
                                break
                        ops.append('op' + ot)
                    else:
                        mm = re.match(r'\\_\w+: (\(([^)]*)\))?', s)
                        ops.append(kind + ('(' + (mm.group(2) or '') + ')'
                                           if mm and mm.group(2) else ''))
            a += 1
        out.append((sect, name, loc, 'op=%s ts=%s ops=[%s]' % (op, ts,
                                                              ' '.join(ops))))
    return out


if __name__ == '__main__':
    for p in sys.argv[1:]:
        print('## ' + p)
        for sect, name, loc, d in parse(p):
            print('  %-16s %-34s %-14s %s' % (sect or '?', name, loc, d))
