#!/usr/bin/env python3
"""List RETURN-NAME reference binding disagreements, one line each, tagged
OVERBIND (golden unbound / ours bound) or UNDERBIND (golden bound / ours not),
and NOREF when one side has no reference object at that key at all.
    retlist.py <g.cen> <o.cen> [OVERBIND|UNDERBIND|NOREF]
"""
import re
import sys

LINE = re.compile(r"^(\S+) (\S+) \| (\S+) '([^']*)' (\d+:\d+) -> (.*) @ (.*)$")


def load(p):
    rows = {}
    for ln in open(p):
        m = LINE.match(ln.rstrip('\n'))
        if m:
            v, tf, k, n, pos, a, c = m.groups()
            rows[(v, tf, k, n, pos)] = (a, c)
    return rows


def last(tf):
    s = tf
    for sep in ('::', '.'):
        if sep in s:
            s = s.split(sep)[-1]
    return s


g = load(sys.argv[1])
o = load(sys.argv[2])
want = sys.argv[3] if len(sys.argv) > 3 else None
n = 0
for k in sorted(set(g) | set(o)):
    if not (k[3] and k[3] == last(k[1])):
        continue
    ga, oa = g.get(k), o.get(k)
    if ga is None or oa is None:
        tag = 'NOREF'
    else:
        gb = ga[0] not in (None, '-')
        ob = oa[0] not in (None, '-')
        if gb == ob:
            continue
        tag = 'OVERBIND' if ob else 'UNDERBIND'
    if want and tag != want:
        continue
    n += 1
    print('%-9s %-8s %-52s %-9s %-9s g=%-26s o=%-26s ctx=%s'
          % (tag, k[0], k[1], k[2], k[4],
             (ga[0] if ga else 'NOREF'), (oa[0] if oa else 'NOREF'),
             (oa[1] if oa else (ga[1] if ga else '?'))))
print('# %d rows' % n)
