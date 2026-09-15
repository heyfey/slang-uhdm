#!/usr/bin/env python3
"""r11u47 SHAPE LISTER — every struct/union/enum typespec in a uhdm-dump,
keyed (kind, line:col..endline:endcol), with its stored VpiName and whether a
vpiInstance line follows.  Depth-keyed, NOT slot-keyed; duplicates are KEPT
(multiset) and reported with their counts."""
import re, subprocess, sys, collections

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
KINDS = ('struct_typespec', 'union_typespec', 'enum_typespec')

def rows(path):
    txt = subprocess.run([DUMP, path], capture_output=True, text=True).stdout
    lines = txt.split('\n')
    out = []
    for i, ln in enumerate(lines):
        m = re.match(r'^(\s*)\\_(' + '|'.join(KINDS) + r'): (\(([^)]*)\))?,?\s*(line:(\S+), endln:(\S+))?', ln)
        if not m:
            continue
        indent = len(m.group(1))
        kind = m.group(2)
        nm = m.group(4) or ''
        loc = (m.group(6) or '?') + '..' + (m.group(7) or '?')
        # scan the children of THIS node (strictly deeper indent, until we
        # return to <= indent) for the object's own vpiInstance / vpiName
        inst = ''
        name = ''
        j = i + 1
        want = indent + 2
        while j < len(lines):
            l2 = lines[j]
            if l2.strip() == '':
                break
            ind2 = len(l2) - len(l2.lstrip())
            if ind2 < want:
                break
            if ind2 == want and l2.lstrip().startswith('|vpiName:'):
                name = l2.split('|vpiName:', 1)[1].strip()
            if ind2 == want and l2.lstrip().startswith('|vpiInstance:'):
                inst = lines[j+1].strip()[2:].split(',')[0] if j+1 < len(lines) else 'YES'
            if ind2 == want and l2.lstrip().startswith('|vpiTypespecMember'):
                break
            j += 1
        out.append((kind, loc, name or nm, inst))
    return out

def census(path):
    c = collections.Counter(rows(path))
    return c

if __name__ == '__main__':
    a = census(sys.argv[1])
    if len(sys.argv) > 2:
        b = census(sys.argv[2])
        keys = sorted(set(a) | set(b))
        print('%-6s %-16s %-26s %-24s %-28s' % ('cnt', 'kind', 'loc', 'name', 'instance'))
        for k in keys:
            ca, cb = a.get(k, 0), b.get(k, 0)
            flag = '   ' if ca == cb else ' * '
            print('%s%2d/%-2d %-16s %-26s %-24s %-28s' % (flag, ca, cb, k[0], k[1], k[2] or '-', k[3] or '-'))
    else:
        for k, v in sorted(a.items()):
            print('%2d %-16s %-26s %-24s %-28s' % (v, k[0], k[1], k[2] or '-', k[3] or '-'))
