#!/usr/bin/env python3
"""r10uvm162repro/slice162.py — cut a `uhdm-dump` into one slice per CLASS
METHOD and compare the two sides cell by cell.  MEASUREMENT ONLY; the official
`uhdm-cmp` is the judge.

A slice runs from the `\\_function:`/`\\_task:` header that a `|vpiMethod:` line
INTRODUCES (a header at any other place is a `vpiParent` back-reference) to the
next such header.  The workdir path is normalised away (dump paths embed the
workdir, RESUME.md §9) and the `, id:NNN` serializer ids are dropped, so two
slices are equal exactly when the two databases hold the same objects with the
same read fields at the same spans.

usage: slice162.py <a.dump> <b.dump> [--print CELL] [--only PREFIX]
       LHS is the FIRST file (always golden in this pass's tables).
"""
import re
import sys

HDR = re.compile(r'^(\s*)\\_(?:function|task): \(([^)]*)\)')


def slices(path):
    out, cur, name, prev = {}, None, None, ''
    for ln in open(path, errors='replace'):
        ln = ln.rstrip('\n')
        m = HDR.match(ln)
        if m and prev.strip() == '|vpiMethod:':
            if name is not None and name not in out:
                out[name] = cur
            name = m.group(2).split('::')[-1]
            cur = []
        prev = ln
        if cur is not None:
            cur.append(norm(ln))
    if name is not None and name not in out:
        out[name] = cur
    return out


def norm(ln):
    ln = re.sub(r'file:[^,]*,', 'file:<>,', ln)
    ln = re.sub(r', id:\d+', '', ln)
    return ln


def main():
    a, b = sys.argv[1], sys.argv[2]
    pr = only = None
    argv = sys.argv[3:]
    while argv:
        if argv[0] == '--print':
            pr = argv[1]; argv = argv[2:]
        elif argv[0] == '--only':
            only = argv[1]; argv = argv[2:]
        else:
            argv = argv[1:]
    A, B = slices(a), slices(b)
    if pr:
        for ln in A.get(pr, ['<absent>']):
            print(ln)
        return
    names = sorted(set(A) | set(B))
    same = diff = 0
    for n in names:
        if only and not n.startswith(only):
            continue
        if n not in A:
            print('ONLY-B  ' + n); diff += 1
        elif n not in B:
            print('ONLY-A  ' + n); diff += 1
        elif A[n] == B[n]:
            same += 1
        else:
            print('DIFF    %-12s A=%d B=%d lines' % (n, len(A[n]), len(B[n])))
            diff += 1
    print('SAME=%d DIFF=%d' % (same, diff))


if __name__ == '__main__':
    main()
