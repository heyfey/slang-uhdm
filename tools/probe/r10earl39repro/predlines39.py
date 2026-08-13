#!/usr/bin/env python3
"""r10earl39 — the LINE-LEVEL prediction, derived from the PRISTINE dump alone.

Given the census's mover list (the DEF-VIEW GENERATE-BRANCH PROCESS actuals that
carry a `vpiTypespec` on our side), this walks the pristine dump, finds each of
those objects, and prints the EXACT dump lines its `vpiTypespec` subtree
occupies — as a per-shape multiset.  Those lines, and only those, may disappear
from the patched dump.

Run it BEFORE the patched build so the prediction cannot be shaped by the
result.

usage: predlines39.py <pristine.dump>
"""
import collections
import re
import sys

OBJ = re.compile(r'^( *)\\_([A-Za-z_0-9]+): *(\([^)]*\))?(.*)$')
FLD = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')
# The head's ancestor signature: a generate BRANCH construct, then a process.
GENBR = ('gen_if', 'gen_if_else', 'gen_case')
PROC = ('always', 'initial')
CALL = ('func_call', 'task_call', 'method_func_call')


def main():
    path = sys.argv[1]
    stack = []          # [indent, kind, label]
    labels = {}
    skip = None
    cap = None          # (indent_of_field, [lines])
    shapes = collections.Counter()
    objs = 0
    for raw in open(path, errors='replace'):
        line = raw.rstrip('\n')
        if cap is not None:
            m = FLD.match(line) or OBJ.match(line)
            ind = len(m.group(1)) if m else 0
            # The ref_typespec itself is printed AT THE LABEL'S INDENT (that is
            # how uhdm-dump renders a singular child); its own fields are deeper.
            if m and (ind > cap[0] or (len(cap[1]) == 1 and ind == cap[0])):
                cap[1].append(line)
                continue
            for l in cap[1]:
                shapes[l] += 1
            objs += 1
            cap = None
        m = FLD.match(line)
        if m:
            ind = len(m.group(1))
            if skip is not None and ind > skip:
                continue
            skip = None
            labels[ind] = m.group(2)
            if m.group(2) == 'vpiParent':
                skip = ind
                continue
            # The owner of a field at indent I is the object at indent I-2.  It
            # is NOT necessarily stack[-1]: uhdm-dump prints an object's parent
            # as a shallow back-reference stub AT THE SAME INDENT as the
            # `|vpiParent:` label that introduces it, so a stub can sit on top
            # of the stack.  Find the owner by indent, and take the ancestor
            # chain from below it.
            oi = next((j for j in range(len(stack) - 1, -1, -1)
                       if stack[j][0] == ind - 2), None)
            if m.group(2) == 'vpiTypespec' and oi is not None:
                e = stack[oi]
                anc = [k for (_i, k, _l) in stack[:oi]]
                if (e[2] == 'vpiArgument' and anc and anc[-1] in CALL and
                        any(a in GENBR for a in anc) and
                        any(a in PROC for a in anc) and
                        _order_ok(anc)):
                    cap = (ind, [line])
            continue
        m = OBJ.match(line)
        if not m:
            continue
        ind = len(m.group(1))
        if skip is not None and ind > skip:
            continue
        skip = None
        while stack and stack[-1][0] >= ind:
            stack.pop()
        stack.append([ind, m.group(2), labels.get(ind, '?')])
    if cap is not None:
        for l in cap[1]:
            shapes[l] += 1
        objs += 1
    print('PREDICTED MOVER OBJECTS: %d' % objs)
    print('PREDICTED LINES REMOVED: %d (0 added)' % sum(shapes.values()))
    print('--- per-shape multiset (exact dump lines, indentation significant)')
    for l, n in sorted(shapes.items(), key=lambda kv: (-kv[1], kv[0])):
        print('  %4d  %s' % (n, l))


def _order_ok(anc):
    """A generate BRANCH must come BEFORE the process in the chain (a process
    containing a gen construct is impossible, but a `begin` named the same is
    not, so the order is asserted rather than assumed)."""
    gi = min((i for i, a in enumerate(anc) if a in GENBR), default=None)
    pi = min((i for i, a in enumerate(anc) if a in PROC), default=None)
    return gi is not None and pi is not None and gi < pi


if __name__ == '__main__':
    main()
