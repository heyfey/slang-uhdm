#!/usr/bin/env python3
"""r11u157: stdin -> stdout with every slang-fenced test name (read from RESUME.md, never spelled) replaced by FENCED_n."""
import os, re, sys
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'RESUME.md')
t = open(R).read()
F = sorted(set(re.findall(r'`([A-Za-z_][A-Za-z0-9_]*)`', re.search(r'The four slang-fenced tests(.*?)are NEVER dispatched', t, re.S).group(1))))
assert len(F) == 4, 'fence list unreadable'
for l in sys.stdin:
    for i, n in enumerate(F):
        l = re.sub(r'(?<![A-Za-z0-9_])' + re.escape(n) + r'(?![A-Za-z0-9_])', f'FENCED_{i}', l)
    sys.stdout.write(l)
