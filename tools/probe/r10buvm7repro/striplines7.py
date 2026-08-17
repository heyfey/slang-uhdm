#!/usr/bin/env python3
"""r10buvm7 — remove from a uhdm-dump every OBJECT BLOCK anchored at one of the
given SOURCE LINES, plus every single line that itself names one of them.

§ lvIncDecSelMemberCollapse7 replaces a hier_path SUBTREE with ONE ref_obj.
Every object it adds or removes is spanned inside the inc/dec statement's own
source line, so removing those statements' blocks from BOTH dumps is an
ATTRIBUTION: what remains must be identical as a LINE MULTISET.

Why BLOCKS and not lines: a dump's FIELD lines (`|vpiName:used`,
`|vpiActual:`) carry NO `line:` text at all, so a line filter leaves the
removed hier_path's fields behind and reports them as residue.  The first
version of this script did exactly that and its own POSITIVE CONTROL caught it
— which is why the control is mandatory (r10buvm6's boundary check learned the
same lesson about field-label regexes).

A block = a header line (`<indent>\\_kind: ...`) plus every following line with
STRICTLY GREATER indentation.

  usage: striplines7.py <dump> <N> [<N> ...]
Prints the filtered dump on stdout, and on stderr how many lines it removed —
a filter that removed nothing must never read as a clean attribution.
"""
import re, sys

dump = sys.argv[1]
lines = set(int(x) for x in sys.argv[2:])
pat = re.compile(r'line:(\d+):')
hdr = re.compile(r'^(\s*)\\_')

src = open(dump, errors='replace').readlines()
out = []
drop = 0
i = 0
while i < len(src):
    l = src[i]
    hit = any(int(m) in lines for m in pat.findall(l))
    m = hdr.match(l)
    if hit and m:
        ind = len(m.group(1))
        # the bare field LABEL this object is the value of
        if out and re.match(r'^\s*\|\w+:\s*$', out[-1]):
            m3 = re.match(r'^(\s*)\|', out[-1])
            if m3 and len(m3.group(1)) == ind:
                out.pop()
                drop += 1
        i += 1
        drop += 1
        while i < len(src):
            m2 = re.match(r'^(\s*)\S', src[i])
            if m2 and len(m2.group(1)) > ind:
                i += 1
                drop += 1
            else:
                break
        continue
    if hit:
        drop += 1
        i += 1
        continue
    out.append(l)
    i += 1
sys.stdout.writelines(out)
sys.stderr.write("striplines7: kept=%d dropped=%d lines=%s\n" %
                 (len(out), drop, sorted(lines)))
