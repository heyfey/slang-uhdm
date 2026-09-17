#!/usr/bin/env python3
# r11u59 SHAPE LISTER (the VALUE half) — for each param_assign in a uhdm-dump
# section, print every assignment-pattern ELEMENT with its member tag, its
# object kind, and the three fields the mask law touches:
#   vpiSize / the value field (UINT:/INT:/BIN:/DEC:/HEX:) / vpiDecompile.
# sz58.py prints the SIZE half only; this one is what R2 needs.
# It also reports whether the listing is TAGGED (tagged_pattern operands) or
# FLAT (positional) — the R0 flatten census reads that column.
# Measurement only; the judge is uhdm-cmp.
#
# usage: sz59.py <dump> <section-substring> [--flat-only]
import sys, os, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shape54 as S

VALFLD = ('UINT', 'INT', 'BIN', 'DEC', 'HEX', 'REAL', 'STRING')


def scalars(block):
    out = {}
    for name, sval, blk in S.fields(block):
        if sval is not None:
            out[name] = sval
    return out


def cell(blk):
    """One pattern element -> 'kind:size/value/decompile'."""
    kind, nm, loc = S.head_of(blk)
    sc = scalars(blk)
    sz = sc.get('vpiSize', '-')
    val = '-'
    for v in VALFLD:
        if v in sc:
            val = v + ':' + sc[v]
            break
    dec = sc.get('vpiDecompile', '-')
    return f"{kind[:5]}:{sz}/{val}/{dec}"


def elements(rhsblk):
    """Yield (tag, elementblock) for an assignment-pattern Rhs.
       tag is the tagged_pattern's member name, or '#<i>' when positional."""
    ops = []
    for name, sval, blk in S.fields(rhsblk):
        if name == 'vpiOperand' and blk:
            ops.append(blk)
    i = 0
    for blk in ops:
        kind, nm, loc = S.head_of(blk)
        if kind == 'tagged_pattern':
            tag = '?'
            inner = None
            for n2, s2, b2 in S.fields(blk):
                if n2 == 'vpiTypespec' and b2:
                    for n3, s3, b3 in S.fields(b2):
                        if n3 == 'vpiActual' and b3:
                            k3, nm3, l3 = S.head_of(b3)
                            tag = nm3 or ('<' + k3 + '>')
                if n2 == 'vpiPattern' and b2:
                    inner = b2
            yield tag, inner
        else:
            yield '#%d' % i, blk
        i += 1


def main():
    path, want = sys.argv[1], sys.argv[2]
    flatonly = '--flat-only' in sys.argv[3:]
    lines = open(path, errors='replace').read().split('\n')
    sect = '?'
    i = 0
    while i < len(lines):
        l = lines[i]
        if S.SECT.match(l):
            sect = l.strip().lstrip('|').rstrip(':')
            i += 1
            continue
        if l.lstrip().startswith('\\_param_assign:'):
            blk, nxt = S.subtree(lines, i)
            name, rhs = '?', None
            for fn, sv, b in S.fields(blk):
                if fn == 'vpiLhs' and b:
                    k2, n2, l2 = S.head_of(b)
                    name = n2 or ('<' + k2 + '>')
                if fn == 'vpiRhs' and b:
                    rhs = b
            if rhs is not None and want in sect:
                k, nm, loc = S.head_of(rhs)
                cells = []
                tagged = 0
                for tag, eb in elements(rhs):
                    if not tag.startswith('#'):
                        tagged += 1
                    cells.append(f"{tag}={cell(eb) if eb else '<null>'}")
                if cells:
                    shape = 'TAGGED' if tagged else 'FLAT'
                    if not flatonly or shape == 'FLAT':
                        print(f"{name:24s} {shape:6s} " + " ".join(cells))
            i = nxt
            continue
        i += 1


main()
