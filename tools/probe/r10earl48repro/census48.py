#!/usr/bin/env python3
"""r10earl48 census — ELAB-view generate-scope PATHS, golden vs ours.

Reads two uhdm-dump outputs (first line already stripped) and, in the
uhdmtopModules region ONLY (the ELABORATED view; the uhdmallModules region is
the DEF view and carries named_begin, not gen_scope_array), collects every
gen_scope_array's vpiFullName together with its printed span.

The DEF view is deliberately EXCLUDED: prim_present's def view names
work@prim_present.gen_round.gen_enc.gen_d64 and is identical on both sides,
so merging the views would hide the elab-only flatten (r10earl47 R-4).

Output:
  * the two path SETS and their symmetric difference
  * for every OURS-ONLY path, whether deleting exactly ONE component yields a
    GOLDEN path (a "dropped level") and which component that is
  * the dropped-level population grouped by (module, dropped component name)
"""
import sys, re
from collections import defaultdict, Counter

def load(path):
    with open(path) as f:
        lines = f.readlines()
    # find the topModules region: from the first line '|uhdmtopModules:' to EOF
    start = None
    for i, l in enumerate(lines):
        if l.startswith('|uhdmtopModules:'):
            start = i
            break
    if start is None:
        sys.exit("no |uhdmtopModules: in " + path)
    return lines, start

GSA = re.compile(r'^(\s*)\\_gen_scope_array: \(([^)]*)\)(?:, line:(\d+):(\d+), endln:(\d+):(\d+))?')

def paths(lines, start):
    """Every gen_scope_array DECLARATION (the one that carries |vpiName: right
    after it) -> (fullname, span).  A gen_scope_array printed as a vpiParent
    back-reference has NO |vpiName: line following, so it is skipped."""
    out = {}
    n = len(lines)
    for i in range(start, n):
        m = GSA.match(lines[i])
        if not m:
            continue
        ind = len(m.group(1))
        # a declaration is followed (within a few lines) by |vpiName: at ind+2
        name = None
        full = None
        j = i + 1
        while j < n:
            l = lines[j]
            if not l.startswith(' ' * (ind + 2) + '|'):
                if l.startswith(' ' * (ind + 2) + '\\_'):
                    j += 1
                    continue
                break
            if l.startswith(' ' * (ind + 2) + '|vpiName:'):
                name = l.split(':', 1)[1].rstrip('\n')
            elif l.startswith(' ' * (ind + 2) + '|vpiFullName:'):
                full = l.split(':', 1)[1].rstrip('\n')
                break
            j += 1
        if name is None or full is None:
            continue
        span = (m.group(3), m.group(4), m.group(5), m.group(6))
        out.setdefault(full, []).append(span)
    return out

gl, gs = load(sys.argv[1])
ol, os_ = load(sys.argv[2])
G = paths(gl, gs)
O = paths(ol, os_)
print("golden elab gen_scope_array fullnames: %d distinct" % len(G))
print("ours   elab gen_scope_array fullnames: %d distinct" % len(O))
gonly = sorted(set(G) - set(O))
oonly = sorted(set(O) - set(G))
both = sorted(set(G) & set(O))
print("shared: %d   GOLDEN-ONLY: %d   OURS-ONLY: %d" % (len(both), len(gonly), len(oonly)))

# span disagreements among the shared ones
spandiff = [p for p in both if G[p][0] != O[p][0]]
print("shared paths with a DIFFERENT span: %d" % len(spandiff))
for p in spandiff[:40]:
    print("   SPAN %s  golden=%s ours=%s" % (p, G[p][0], O[p][0]))
if len(spandiff) > 40:
    print("   ... %d more" % (len(spandiff) - 40))

def comps(p):
    # work@mod.a.b[0].c  ->  ('work@mod', 'a', 'b[0]', 'c')
    return p.split('.')

drop1 = defaultdict(list)   # (module, dropped-component) -> [ours path]
nodrop = []
for p in oonly:
    c = comps(p)
    hit = None
    for k in range(1, len(c)):
        cand = '.'.join(c[:k] + c[k + 1:])
        if cand in G:
            hit = (k, c[k], cand)
            break
    if hit:
        drop1[(c[0], hit[1])].append((p, hit[2]))
    else:
        nodrop.append(p)
print()
print("OURS-ONLY paths explained by deleting EXACTLY ONE component: %d"
      % sum(len(v) for v in drop1.values()))
print("OURS-ONLY paths NOT so explained: %d" % len(nodrop))
print()
print("--- dropped-level population, by (module, dropped component) ---")
for k in sorted(drop1, key=lambda k: -len(drop1[k])):
    ex = drop1[k][0]
    print("  %-40s drop %-18s x%-5d  e.g. %s  ->  %s"
          % (k[0], k[1], len(drop1[k]), ex[0], ex[1]))
print()
print("--- OURS-ONLY not explained by a single drop (first 60) ---")
for p in nodrop[:60]:
    print("   " + p)
if len(nodrop) > 60:
    print("   ... %d more" % (len(nodrop) - 60))
print()
print("--- GOLDEN-ONLY (first 60) ---")
for p in gonly[:60]:
    print("   " + p)
if len(gonly) > 60:
    print("   ... %d more" % (len(gonly) - 60))
