#!/usr/bin/env python3
"""r10uvm162repro/twin162.py — THE ORACLE PROOF.

For every `ok_<cell>` / `bd_<cell>` pair in ONE database, cut the assignment's
`vpiRhs` concatenation, DEDENT it (a `bd_` twin's body sits one `begin` block
deeper, because it declares the type-parameter local that makes the operand
bad), erase spans and the method name, drop the trailing operand the `bd_` twin
adds (the bad `t.gt()`), and compare what is left.

A pair that reads TWIN says: golden's object inside a REJECTED concatenation is
field-for-field its ACCEPTED twin's — which is exactly what makes the accepted
twin an ORACLE for the recovery, and what lets a grid cell be scored without
guessing.  Run it on OUR database too: there a `bd_` cell reads NOTTWIN
wherever the law abstains (an empty operand vector) and TWIN wherever it
recovers.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.

usage: twin162.py <dump> [--verbose] [--cell NAME]
"""
import re
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from slice162 import slices  # noqa: E402


def rhs(lines):
    """The `vpiRhs:` payload of the FIRST assignment in the slice, dedented."""
    out, on, ind = [], False, None
    for ln in lines:
        s = ln.strip()
        if not on and s == '|vpiRhs:':
            on, ind = True, len(ln) - len(ln.lstrip())
            continue
        if on and s == '|vpiLhs:' and len(ln) - len(ln.lstrip()) == ind:
            break
        if on:
            out.append(ln[ind:] if ln[:ind].strip() == '' else ln.lstrip())
    return out


def scrub(lines, name):
    out = []
    for ln in lines:
        ln = re.sub(r'line:\d+:\d+, endln:\d+:\d+', 'SPAN', ln)
        ln = re.sub(r'\b(ok|bd)_' + re.escape(name) + r'\b', 'CELL', ln)
        out.append(ln)
    return out


def top_operands(lines):
    """Indices of the `|vpiOperand:` lines of the OUTERMOST operation."""
    if not lines:
        return []
    ind = len(lines[0]) - len(lines[0].lstrip()) + 2
    return [i for i, ln in enumerate(lines)
            if ln.strip() == '|vpiOperand:' and len(ln) - len(ln.lstrip()) == ind]


def main():
    S = slices(sys.argv[1])
    verbose = '--verbose' in sys.argv
    want = sys.argv[sys.argv.index('--cell') + 1] if '--cell' in sys.argv else None
    cells = sorted(n[3:] for n in S if n.startswith('ok_'))
    same = diff = miss = 0
    for c in cells:
        if 'bd_' + c not in S or (want and c != want):
            continue
        ok = scrub(rhs(S['ok_' + c]), c)
        bd = scrub(rhs(S['bd_' + c]), c)
        keep = len(top_operands(ok))
        idx = top_operands(bd)
        if len(idx) > keep:
            bd = bd[:idx[keep]]
        if not ok or not bd:
            print('EMPTY   ' + c); miss += 1
        elif ok == bd:
            same += 1
            if verbose:
                print('TWIN    ' + c)
        else:
            print('NOTTWIN %-6s ok=%d bd=%d lines' % (c, len(ok), len(bd)))
            diff += 1
            if want:
                import difflib
                for l in difflib.unified_diff(ok, bd, 'ok', 'bd', lineterm='', n=1):
                    print(l)
    print('TWIN=%d NOTTWIN=%d EMPTY=%d' % (same, diff, miss))


if __name__ == '__main__':
    main()
