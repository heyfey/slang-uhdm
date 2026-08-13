#!/usr/bin/env python3
"""r10earl35 — net-type census.

Walks a uhdm-dump (already `sed 1d`) and, for every `*_net:` object header,
records (kind, name, span) -> the vpiNetType it prints (or '-' when absent).
The span is part of the key so two nets with the same name in different
modules never collide, and a MULTISET count is kept so repeated instances
are visible instead of silently merged.

usage: netcen.py <dump>  -> stdout "kind|name|span|nettype  COUNT"
"""
import re
import sys
from collections import Counter

HDR = re.compile(r'^(\s*)\\_(\w*_net): \(([^)]*)\)(.*)$')
FLD = re.compile(r'^(\s*)\|vpi(\w+):(.*)$')

def main():
    cnt = Counter()
    cur = None      # (indent, kind, name, span)
    nt = None
    with open(sys.argv[1], 'rt', errors='replace') as f:
        for line in f:
            line = line.rstrip('\n')
            m = HDR.match(line)
            if m:
                if cur is not None:
                    cnt[cur + (nt,)] += 1
                indent = len(m.group(1))
                span = m.group(4).strip().lstrip(',').strip()
                cur = (indent, m.group(2), m.group(3), span)
                nt = '-'
                continue
            if cur is None:
                continue
            m2 = FLD.match(line)
            if m2:
                # only fields of THIS object (indent == obj indent + 2)
                if len(m2.group(1)) == cur[0] + 2 and m2.group(2) == 'NetType':
                    nt = m2.group(3).strip()
                continue
            # a nested object header of another kind: keep scanning, the
            # indent guard above already rejects its fields.
    if cur is not None:
        cnt[cur + (nt,)] += 1
    # INDENT IS NOT IDENTITY: the same object is printed at several depths
    # (once in place, again under every vpiActual/vpiNet back-reference).
    # Fold the indent out of the key AFTER counting, summing the buckets, or
    # two depths of one object print as two identical lines and a naive
    # loader silently keeps only the last.
    out = Counter()
    for k, v in cnt.items():
        out[(k[1], k[2], k[3], k[4])] += v
    for k, v in sorted(out.items()):
        print('%s|%s|%s|%s\t%d' % (k[0], k[1], k[2], k[3], v))

main()
