#!/usr/bin/env python3
"""r11u5 — per-typespec FOLD census, tagged by the DESIGN LISTING the block was
found in (uhdmallPackages / uhdmtopPackages / uhdmallModules / uhdmtopModules).

For every logic_/packed_array_typespec block: the listing, the owner it hangs
under, and for each of its OWN vpiRanges the shape of the LEFT bound
(constant = folded, operation/ref_obj = unfolded).  Also reports, for a range
bound that is an operation, whether a $clog2 argument inside it is folded.
"""
import re
import sys

ID = re.compile(r', id:\d+')
TS = re.compile(r'^(\s*)\\_((?:logic|packed_array)_typespec):(.*)$')
LISTINGS = ('|uhdmallPackages:', '|uhdmtopPackages:',
            '|uhdmallModules:', '|uhdmtopModules:')


def indent(s):
    return len(s) - len(s.lstrip())


def run(path):
    lines = open(path, 'rt', errors='replace').read().splitlines()
    marks = [(i, l.strip().rstrip(':').lstrip('|'))
             for i, l in enumerate(lines) if l.strip() in LISTINGS]
    rows = []
    for i, ln in enumerate(lines):
        m = TS.match(ln)
        if not m:
            continue
        sec = [n for j, n in marks if j < i]
        sec = sec[-1] if sec else 'ROOT'
        base = indent(ln)
        j = i + 1
        while j < len(lines):
            if lines[j].lstrip().startswith('\\_') and indent(lines[j]) <= base:
                break
            j += 1
        blk = lines[i:j]
        owner = ''
        for k, b in enumerate(blk):
            if b.strip() == '|vpiParent:' and k + 1 < len(blk):
                owner = ID.sub('', blk[k + 1].strip())
                break
        bounds = []
        for k, b in enumerate(blk):
            if b.strip() != '|vpiRange:' or indent(b) != base + 2:
                continue
            # the range's own extent, so a nested bound is read from it alone
            rb = indent(blk[k + 1])
            k9 = k + 2
            while k9 < len(blk) and not (blk[k9].lstrip().startswith('\\_')
                                         and indent(blk[k9]) <= rb):
                k9 += 1
            rng = blk[k + 1:k9]
            shape = '?'
            for k2, b2 in enumerate(rng):
                if b2.strip() == '|vpiLeftRange:':
                    shape = rng[k2 + 1].strip().split(':')[0].lstrip('\\_')
                    break
            # a $clog2 inside this range: is its ARGUMENT folded?
            for k2, b2 in enumerate(rng):
                if 'sys_func_call: ($clog2)' in b2:
                    for k3 in range(k2 + 1, len(rng)):
                        if rng[k3].strip() == '|vpiArgument:':
                            a = rng[k3 + 1].strip().split(':')[0].lstrip('\\_')
                            shape += '/clog2arg=' + a
                            break
                    break
            bounds.append(shape)
        if bounds:
            rows.append((i + 1, sec, ID.sub('', m.group(2) + ':' + m.group(3)),
                         owner, bounds))
    return rows


if __name__ == '__main__':
    for path in sys.argv[1:]:
        print('##', path)
        for lno, sec, ts, owner, bounds in run(path):
            print('  L%-6d %-16s %-34s owner=%-44s %s'
                  % (lno, sec, ts[:34], owner[:44], bounds))
        print()
