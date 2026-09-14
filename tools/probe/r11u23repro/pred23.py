#!/usr/bin/env python3
# r11u23 A-PRIORI MOVER PREDICTION — reads PRISTINE databases ONLY.
#
# A database with no flagged cell cannot move under
# § genCaUnboundTernFold23 / § genCaUnboundTernLhsNoActual23.  The scan is a
# DELIBERATE SUPERSET: it flags every ELABORATED gen-scope `cont_assign` whose
# Rhs is a `vpiOpType:32` (vpiConditionOp) operation and whose Lhs is a whole
# `ref_obj`.  It cannot see whether `bindVariable` finds the target, it cannot
# apply the operand gate over the untaken arm, it cannot evaluate the
# condition, and it cannot tell an installable arm from a declined one.  It
# over-flags by design; the requirement it answers is CONTAINMENT — no
# database outside the flagged set can move.
#
# Per cell it also records the two things that decide EXPOSURE:
#   ACT=1    our pristine Lhs ref_obj already carries a `vpiActual`  (FACE A:
#            only such a cell can LOSE one)
#   UNS=1    some constant inside the Rhs tree has `vpiSize:-1`      (the
#            `DetectUnsizedConstant` clone trigger, UhdmWriter.cpp:2288)
#
# `owner == gen_scope` selects the ELABORATED rows on its own: a definition-
# listing generate block owns its cont_assigns through a `named_begin`, and no
# law of this pass touches the definition view.
#
# NO SECTIONING — `|uhdmallModules:` / `|uhdmtopModules:` are REPEATED keys,
# not two contiguous sections (r11u19's own bug); the whole dump is walked,
# which only widens the superset.
#
# usage: pred23.py <dump> [<dump> ...]     ('-' reads stdin)
import re, sys


def _read(path):
    if path == '-':
        return sys.stdin.read().split('\n')
    return open(path, errors='replace').read().split('\n')


def scan(path, L=None):
    L = list(L) if L is not None else _read(path)
    hits = []
    for i, ln in enumerate(L):
        m = re.search(r'\\_cont_assign: , (?:file:\S+, )?line:(\d+):(\d+)', ln)
        if not m:
            continue
        if i and L[i - 1].strip() == '|vpiParent:':
            continue
        ind = len(ln) - len(ln.lstrip())
        owner, lhs, op32, lhsref, act, uns = '?', '?', False, False, False, False
        j = i + 1
        while j < len(L):
            s = L[j]
            k = len(s) - len(s.lstrip())
            if k <= ind:
                break
            t = s.strip()
            if t == '|vpiParent:' and owner == '?':
                owner = L[j + 1].strip().split(':')[0].lstrip('\\_')
            if t == '|vpiRhs:':
                a = L[j + 1]
                if a.strip().startswith('\\_operation:'):
                    ri = len(a) - len(a.lstrip())
                    q = j + 2
                    while q < len(L):
                        s2 = L[q]
                        k2 = len(s2) - len(s2.lstrip())
                        if k2 <= ri:
                            break
                        if k2 == ri + 2 and s2.strip() == '|vpiOpType:32':
                            op32 = True
                        if s2.strip() == '|vpiSize:-1':
                            uns = True
                        q += 1
            if t == '|vpiLhs:':
                a = L[j + 1]
                if a.strip().startswith('\\_ref_obj:'):
                    lhsref = True
                    mm = re.search(r'\((.*?)\)', a)
                    lhs = mm.group(1) if mm else '?'
                    li = len(a) - len(a.lstrip())
                    q = j + 2
                    while q < len(L):
                        s2 = L[q]
                        k2 = len(s2) - len(s2.lstrip())
                        if k2 <= li:
                            break
                        if k2 == li + 2 and s2.strip() == '|vpiActual:':
                            act = True
                        q += 1
            j += 1
        if owner == 'gen_scope' and op32 and lhsref:
            hits.append((m.group(1) + ':' + m.group(2), lhs, act, uns))
    return hits


if __name__ == '__main__':
    tot = nact = nuns = 0
    for p in sys.argv[1:]:
        h = scan(p)
        tot += len(h)
        nact += sum(1 for x in h if x[2])
        nuns += sum(1 for x in h if x[3])
        if h:
            print(f"{p}: LAW {len(h)} cell(s)")
            for loc, lhs, a, u in h:
                print(f"    LAW {loc:>10} ACT={int(a)} UNS={int(u)} lhs={lhs}")
    print("FLAGGED CELLS: LAW", tot, "ACT", nact, "UNS", nuns,
          "over", len(sys.argv) - 1, "database(s)")
