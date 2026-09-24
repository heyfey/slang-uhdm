#!/usr/bin/env python3
# census_mark.py <census_sites.txt> : MEASUREMENT BUILD ONLY (never landed).
# For every `X->VpiLineNo(...)` write listed by
# tools/probe/r11u122map/drivers/census_vpifile.sh (file:line:text), insert
# `X->VpiFile("CENSUS_<file>_<line>")` right after it, so the per-row record
# dumps name which site minted every file-less located object.  Build, sweep,
# then drivers/census_an.py pairs each marked object with golden's record.
import re, sys, collections
sites = [l.split(':', 2) for l in open(sys.argv[1]).read().splitlines()]
byf = collections.defaultdict(list)
for f, l, t in sites: byf[f].append(int(l))
for f, lst in byf.items():
    p = 'src/' + f
    L = open(p).read().split('\n')
    for l in sorted(lst, reverse=True):
        m = re.match(r'^(\s*)(\w+)->VpiLineNo\(', L[l - 1]); assert m
        L.insert(l, '%s%s->VpiFile("CENSUS_%s_%d");' % (m.group(1), m.group(2), f.replace('.cpp', ''), l))
    open(p, 'w').write('\n'.join(L))
