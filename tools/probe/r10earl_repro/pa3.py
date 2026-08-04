#!/usr/bin/env python3
"""pa3.py <dump...>   per-param_assign projection with value+constType.
One line per param_assign source location; one field group per VIEW."""
import re, sys, collections

for p in sys.argv[1:]:
    print('#####', p)
    cur = None
    groups = collections.OrderedDict()
    fields = {}
    for ln in open(p):
        m = re.search(r'\\_param_assign: , (?:id:\d+, )?line:(\d+):(\d+)', ln)
        if m:
            if cur and fields.get('d') is not None:
                groups.setdefault(cur, []).append(
                    '%s/%s/%s/%s' % (fields.get('d'), fields.get('s', '?'),
                                     fields.get('v', '?'), fields.get('c', '?')))
            cur = m.group(1) + ':' + m.group(2)
            fields = {}
            continue
        if cur is None:
            continue
        m = re.search(r'\|vpiDecompile:(.*)$', ln)
        if m and fields.get('d') is None:
            fields['d'] = m.group(1).rstrip(); continue
        m = re.search(r'\|vpiSize:(-?\d+)', ln)
        if m and 's' not in fields:
            fields['s'] = m.group(1); continue
        m = re.search(r'\|(UINT|INT|HEX|BIN|OCT|DEC|STRING|REAL):(.*)$', ln)
        if m and 'v' not in fields:
            fields['v'] = m.group(1) + ':' + m.group(2).rstrip(); continue
        m = re.search(r'\|vpiConstType:(\d+)', ln)
        if m and 'c' not in fields:
            fields['c'] = m.group(1); continue
    if cur and fields.get('d') is not None:
        groups.setdefault(cur, []).append(
            '%s/%s/%s/%s' % (fields.get('d'), fields.get('s', '?'),
                             fields.get('v', '?'), fields.get('c', '?')))
    for k, v in groups.items():
        print('  %-9s %s' % (k, '   '.join(v)))
