#!/usr/bin/env python3
"""r10earl48 grid reader — the ELAB (uhdmtopModules) generate-scope TREE.

usage: grid48.py <g.dump> <o.dump>

Prints, side by side, every gen_scope_array of the ELABORATED view with its
span and the DIRECT content of its gen_scope (cont_assigns / nets / vars /
child gen_scope_arrays), so a dropped LEVEL and a dropped SIBLING are both
visible.  The DEF (uhdmallModules) view is deliberately excluded: it carries
the same names under named_begin and merging the two hides an elab-only
flatten (r10earl47 R-4 burned exactly that way).
"""
import sys, re

GSA = re.compile(r'^(\s*)\\_gen_scope_array: \(([^)]*)\)(?:, line:(\d+):(\d+), endln:(\d+):(\d+))?')
OBJ = re.compile(r'^(\s*)\\_(\w+): ')


def region(path):
    with open(path) as f:
        lines = f.readlines()
    for i, l in enumerate(lines):
        if l.startswith('|uhdmtopModules:'):
            return lines, i
    sys.exit("no |uhdmtopModules: in " + path)


def scan(path):
    lines, start = region(path)
    n = len(lines)
    out = {}
    for i in range(start, n):
        m = GSA.match(lines[i])
        if not m:
            continue
        ind = len(m.group(1))
        name = full = None
        j = i + 1
        while j < n:
            l = lines[j]
            if l.startswith(' ' * (ind + 2) + '|vpiName:'):
                name = l.split(':', 1)[1].rstrip('\n')
            elif l.startswith(' ' * (ind + 2) + '|vpiFullName:'):
                full = l.split(':', 1)[1].rstrip('\n')
                break
            elif not l.startswith(' ' * (ind + 2)):
                break
            j += 1
        if name is None or full is None:
            continue
        span = "%s:%s-%s:%s" % (m.group(3), m.group(4), m.group(5), m.group(6))
        # DIRECT children of this gsa's gen_scope: field labels at ind+2/+4
        kids = []
        k = i + 1
        depth_prefix = ' ' * (ind + 2)
        while k < n:
            l = lines[k]
            if l.strip() and not l.startswith(depth_prefix):
                break
            mm = re.match(r'^(\s*)\|(vpi\w+):$', l)
            if mm and len(mm.group(1)) == ind + 4:
                nx = lines[k + 1] if k + 1 < n else ''
                om = OBJ.match(nx)
                kids.append(mm.group(2) + '/' + (om.group(2) if om else '?'))
            k += 1
        out[full] = (span, kids)
    return out


g = scan(sys.argv[1])
o = scan(sys.argv[2])
allk = sorted(set(g) | set(o))
print("%-46s %-16s %-16s" % ("ELAB gen path", "golden span", "ours span"))
print("-" * 96)
for k in allk:
    gs = g.get(k)
    os_ = o.get(k)
    mark = ' ' if (gs and os_) else ('G' if gs else 'O')
    print("%s %-44s %-16s %-16s" % (mark, k, gs[0] if gs else '-- ABSENT --',
                                    os_[0] if os_ else '-- ABSENT --'))
    if gs and os_ and gs[0] != os_[0]:
        print("      ^ SPAN DIFFERS")
    if gs:
        print("      golden kids: " + ", ".join(gs[1]))
    if os_:
        print("      ours   kids: " + ", ".join(os_[1]))
print()
print("golden-only: %d   ours-only: %d   shared: %d"
      % (len(set(g) - set(o)), len(set(o) - set(g)), len(set(g) & set(o))))
