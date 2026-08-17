#!/usr/bin/env python3
"""r10buvm6 — remove every `$` CONSTANT BLOCK from a uhdm-dump, so that what is
left is the part of the design THIS PASS DOES NOT CLAIM.

    usage: stripdollar.py <dump> > <stripped>

A `$` constant block is a `\\_constant: , line:L:C, endln:...` line together with
every following line indented DEEPER than it, when that body contains
`|vpiConstType:10`.  The block body includes the `|vpiParent:` label and the
CARRIER line that follows it (`\\_bit_select: …`, `\\_var_select: …`,
`\\_operation: …`), because the dump prints the parent's own header line inside
the child's block — which is exactly the line a line-pattern classifier gets
wrong.  The bare `|vpiIndex:` / `|vpiRightRange:` / `|vpiOperand:` LABEL that
introduces the block sits at the PARENT's indent, one line ABOVE it, so it is
dropped too.

WHY THIS AND NOT A LINE PATTERN: the first version of the boundary checker
classified each differing line against a regex, and its own POSITIVE CONTROL
(this pass's three arms) flagged the carrier lines as "out of law" — the
classifier was under-covering, and on the 63 protected arms, where nothing moved
at all, that defect was invisible.  A checker whose classifier is wrong on the
one input where the answer is known is not a checker.  Stripping whole blocks and
demanding BYTE IDENTITY of the remainder has no classifier to get wrong.
"""
import re
import sys

lines = open(sys.argv[1]).read().split('\n')
CONST = re.compile(r'^(\s*)\\_constant: , line:')
LABEL = re.compile(r'^\s*\|vpi\w+:$')
out = []
i = 0
while i < len(lines):
    m = CONST.match(lines[i])
    if not m:
        out.append(lines[i])
        i += 1
        continue
    ind = len(m.group(1))
    j = i + 1
    while j < len(lines):
        s = lines[j]
        if s.strip() == '':
            j += 1
            continue
        if len(s) - len(s.lstrip()) <= ind:
            break
        j += 1
    body = lines[i:j]
    if any(b.strip() == '|vpiConstType:10' for b in body):
        # drop the introducing label too, if this block is what it introduces
        if out and LABEL.match(out[-1]):
            out.pop()
        i = j
        continue
    out.extend(body)
    i = j
sys.stdout.write('\n'.join(out))
