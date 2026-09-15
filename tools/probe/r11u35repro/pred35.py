#!/usr/bin/env python3
"""r11u35 — name the § typeParamAnonAggMemberNoReduce35 MOVER SET **a priori**.

    pred35.py --selftest                      # the positive control
    pred35.py <corpus-root> [...]             # one PREDICT row per test

WHY THE SOURCE AND NOT THE DATABASE.  Every other prediction in this campaign
reads the PRISTINE databases, because the signature it looks for survives into
them.  This law's does NOT: once the bound is folded, the pristine database
carries a plain `constant` under a `typespec_member`, byte-indistinguishable
from a NAMED typedef's folded member or from a variable's own anonymous
struct.  The only place the distinguishing fact still lives is the SYNTAX the
law itself keys on — an anonymous `struct`/`union` written as the DEFAULT of a
`parameter type` / `localparam type`, with at least one member dimension that
is not a bare integer literal.  So the predictor reads exactly that, out of
every source under each test directory, and the POSITIVE CONTROL proves it can
see: the grid's `g2`/`g3`/`g4` arms MUST be predicted and `g1_site35`
(typedefs only, no type-parameter aggregate default) MUST NOT.

A test predicted here is a candidate MOVER; a test not predicted here must not
move a byte, and any that does is an unexplained mover and fails the gate.
"""
import os
import re
import sys

# `parameter`/`localparam` ... `type` <name> = struct|union ...
TP = re.compile(r'\b(?:parameter|localparam)\s+type\b[^;]*?=\s*(?:struct|union)\b',
                re.S)
# a dimension whose contents are not a bare decimal / sized literal
DIM = re.compile(r'\[([^\]\[]*)\]')
LITERAL = re.compile(r"^\s*(?:\d+|\d*'[sSbBoOdDhH][0-9a-fA-FxXzZ_]+)\s*$")


def aggregate_body(text, start):
    """The brace-balanced body of the aggregate that begins at `start`."""
    i = text.find('{', start)
    if i < 0:
        return ''
    depth, j = 0, i
    while j < len(text):
        if text[j] == '{':
            depth += 1
        elif text[j] == '}':
            depth -= 1
            if depth == 0:
                return text[i:j + 1]
        j += 1
    return text[i:]


def hits(path):
    try:
        text = open(path, encoding='utf-8', errors='replace').read()
    except OSError:
        return []
    out = []
    for m in TP.finditer(text):
        body = aggregate_body(text, m.end() - 1)
        for d in DIM.finditer(body):
            inner = d.group(1)
            for half in inner.split(':'):
                if half.strip() and not LITERAL.match(half):
                    out.append((text[:m.start()].count('\n') + 1,
                                inner.strip()))
                    break
            else:
                continue
            break
    return out


def selftest():
    here = os.path.dirname(os.path.abspath(__file__))
    ok = True
    for arm, want in (('g1_site35', False), ('g2_tpdef35', True),
                      ('g3_shape35', True), ('g4_view35', True)):
        h = hits(os.path.join(here, 'grid', arm, 'dut.sv'))
        got = bool(h)
        print('%-14s predicted=%-5s expected=%-5s %s' %
              (arm, got, want, 'OK' if got == want else 'FAIL'))
        ok = ok and got == want
    print('SELFTEST %s' % ('PASS' if ok else 'FAIL'))
    return 0 if ok else 1


def main():
    if '--selftest' in sys.argv:
        sys.exit(selftest())
    # Each argument is a CORPUS ROOT whose immediate subdirectories are tests
    # (`~/git-repos/uhdm2rtlil/test`, `~/git-repos/Surelog/tests`,
    # `~/git-repos/Surelog/third_party/tests`).  Every source under a test
    # directory is scanned: a `cmds.txt` names its sources RELATIVE to the test
    # directory, not to the workdir, so the workdir is not the oracle here.
    for root in sys.argv[1:]:
        for name in sorted(os.listdir(root)):
            d = os.path.join(root, name)
            if not os.path.isdir(d):
                continue
            found = []
            for dp, _, fns in os.walk(d):
                for f in sorted(fns):
                    if not f.endswith(('.sv', '.v', '.svh', '.vh')):
                        continue
                    for ln, dim in hits(os.path.join(dp, f)):
                        found.append('%s:%d[%s]' % (f, ln, dim))
            if found:
                print('PREDICT %-40s %s' % (name, ' '.join(found[:3])))


if __name__ == '__main__':
    main()
