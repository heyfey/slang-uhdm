#!/usr/bin/env python3
"""r10uvm78repro/ct78gate.py — STATED GATE == CODE GATE, checked MECHANICALLY.

  usage: ct78gate.py <path/to/src/ExprEmit.cpp>

The prose of § everyPartSelIsConstSel78 says the flag is set UNCONDITIONALLY at
every construction site.  A reader can only confirm that by eye, and an eye is
exactly what missed the two accreted gates this pass removed.  So the claim is a
RUN: for each `MakePart_select()` / `MakeIndexed_part_select()` the nearest
following `VpiConstantSelect(true)` must sit at the SAME INDENTATION, which in
this file's style is true iff no `if` (or any other block) was opened between
them.

Also asserts the § partSelBoundPrefixJoinsByScope78 half: there must be ZERO
occurrences of the hard-joined part-select bound prefix
`basePfx = prefix + "." + ...` left, and exactly TWO `basePfx = joinRef(...)`.

Exit 0 = both laws hold in the code; exit 5 = a guarded site; exit 6 = a
hard-joined basePfx survived.  A run that finds ZERO construction sites exits 4
rather than reporting success — an audit that reached nothing must never read as
perfection.
"""
import re
import sys

path = sys.argv[1] if len(sys.argv) > 1 else 'src/ExprEmit.cpp'
src = open(path).read().split('\n')


def ind(l):
    return len(l) - len(l.lstrip())


mk = [(i, ind(l)) for i, l in enumerate(src)
      if 'MakePart_select()' in l or 'MakeIndexed_part_select()' in l]
cs = [(i, ind(l)) for i, l in enumerate(src) if 'VpiConstantSelect(true)' in l]

print('construction sites: %d   flag sites: %d' % (len(mk), len(cs)))
if not mk:
    print('NO CONSTRUCTION SITES FOUND — this audit reached nothing')
    sys.exit(4)

guarded = 0
for mi, mind in mk:
    nxt = [c for c in cs if c[0] > mi]
    if not nxt:
        print('  make@%d  -> NO FLAG AT ALL' % (mi + 1))
        guarded += 1
        continue
    ci, cind = nxt[0]
    ok = cind == mind
    print('  make@%-6d ind=%-3d -> flag@%-6d ind=%-3d  %s'
          % (mi + 1, mind, ci + 1, cind, 'OK' if ok else '*** GUARDED ***'))
    if not ok:
        guarded += 1

# The bound-prefix half lives ONLY in ExprEmit.cpp.  Asserting it against
# TypeEmit.cpp or ModuleEmit.cpp would print a FAIL for a file that never had
# the construct — a guard that fires where it does not apply is worse than no
# guard, so it is scoped by filename and says so when it is skipped.  (Those two
# files hold 10 further construction sites, all already unconditional; run this
# script on them to confirm the flag half.)
txt = '\n'.join(src)
isexpr = path.endswith('ExprEmit.cpp')
if isexpr:
    hard = len(re.findall(r'basePfx = prefix \+ "\."', txt))
    join = len(re.findall(r'basePfx = joinRef\(', txt))
    print('basePfx hard-joined: %d (want 0)   joinRef-joined: %d (want 2)'
          % (hard, join))
else:
    hard, join = 0, 2
    print('basePfx check SKIPPED — not ExprEmit.cpp (flag half only)')

if guarded:
    print('FAIL: %d guarded site(s) — the prose says unconditional' % guarded)
    sys.exit(5)
if hard or join != 2:
    print('FAIL: the bound-prefix joint is not what the law states')
    sys.exit(6)
print('PASS: %d/%d unconditional%s — STATED GATE == CODE GATE'
      % (len(mk), len(mk), ', 2/2 scope-joined' if isexpr else ''))
