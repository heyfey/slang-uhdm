#!/usr/bin/env python3
"""compose_r11u145.py <worktree>: resolve the two conflicts `git apply --3way law.patch` leaves on top of
r11u145.verified.patch's src (both are pair A's files):
  * src/EmitHelpers.h: both blocks append helpers at the end of the namespace; keep r11u145's, close its
    last function (the shared `return on; }` tail), then this pass's block without § defaultFillImportPerElement151.
  * src/ParamEmit.cpp: the default-fill loop; keep r11u145's § defaultFillImportCopies145 (`share145`), the SAME
    rule as § defaultFillImportPerElement151, and drop this pass's DEFPAT lines.
Run from nothing but the worktree; prints what it resolved."""
import re, sys
wt = sys.argv[1]
pat = re.compile(r'^<<<<<<< ours\n(.*?)^=======\n(.*?)^>>>>>>> theirs\n', re.S | re.M)
p = wt + '/src/EmitHelpers.h'
s = open(p).read()
def eh(m):
    ours, theirs = m.group(1), m.group(2)
    return ours + '    return on;\n}\n\n' + theirs
s, n = pat.subn(eh, s)
# the tail after `theirs` is the shared `return on; }` that closes this pass's last helper
a = s.index('/// § defaultFillImportPerElement151')
b = s.index('inline bool defaultFillImportPerElement151On() {', a)
e = s.index('}\n', b) + 2
s = s[:a] + s[e:].lstrip('\n')
s = s.replace('//   R11U151_DEFPAT_OFF  § defaultFillImportPerElement151     (ParamEmit.cpp)\n',
              '//   (DEFPAT: r11u145 § defaultFillImportCopies145 writes the same rule)\n')
open(p, 'w').write(s)
print('EmitHelpers.h conflicts resolved:', n)
p = wt + '/src/ParamEmit.cpp'
s = open(p).read()
a = s.index('                        // § defaultFillImportPerElement151')
b = s.index('                        for (uint32_t i8 = 0; i8 < uat8.range.width(); i8++) {', a)
s = s[:a] + s[b:]
s, n = pat.subn(lambda m: m.group(1), s)
open(p, 'w').write(s)
print('ParamEmit.cpp conflicts resolved:', n)
