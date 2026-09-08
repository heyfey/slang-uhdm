#!/usr/bin/env python3
# r10v221repro/vresidue.py — list the cells that are STILL EXTRA-OURS after the
# patch, so an under-application is named rather than assumed absent.
#   usage: vresidue.py <golden.dump> <pat.dump>
import sys, os, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import importlib.util
spec = importlib.util.spec_from_file_location(
    "vcen", os.path.join(os.path.dirname(os.path.abspath(__file__)), "vcen221.py"))
# vcen221.py runs main() on import, so re-implement the two calls we need here.

def scan(path):
    if not os.path.isfile(path):
        sys.exit("FATAL: no dump at %s" % path)
    lines = open(path, errors='replace').read().split('\n')
    for ti, tl in enumerate(lines):
        if tl.startswith('\\_weaklyReferenced:'):
            lines = lines[:ti]
            break
    import collections
    cells = collections.defaultdict(list)
    n = len(lines)
    for i, l in enumerate(lines):
        m = re.match(r'^(\s*)\\_(ref_obj|ref_var): \(([^)]*)\), line:(\d+):(\d+)', l)
        if not m:
            continue
        ind, fn, ln, col = m.group(1), m.group(3), int(m.group(4)), int(m.group(5))
        payload = 'BARE'
        j = i + 1
        while j < n:
            s = lines[j]
            if s.strip() == '':
                j += 1
                continue
            if len(s) - len(s.lstrip()) <= len(ind):
                break
            mo = re.match(r'^\s*\\_(\w+):\s*\(([^)]*)\)', s)
            if mo and mo.group(1) == 'enum_const':
                payload = 'ACT:enum_const(%s)' % mo.group(2)
            elif re.match(r'^\s*\|vpiActual:', s) and payload == 'BARE':
                payload = 'ACT:' + s.split(':', 1)[1].strip()
            j += 1
        cells[(fn.rsplit('.', 1)[-1], ln, col)].append(payload)
    return {k: sorted(v) for k, v in cells.items()}

G = scan(sys.argv[1])
P = scan(sys.argv[2])
n = 0
for k in sorted(set(G) | set(P)):
    g, p = G.get(k, []), P.get(k, [])
    gk = [x for x in g if x != 'BARE']
    pk = [x for x in p if x != 'BARE']
    if pk and not gk:
        n += 1
        print("STILL-EXTRA-OURS %-14s line %3d col %3d  golden=%s ours=%s"
              % (k[0], k[1], k[2], g, p))
print("STILL-EXTRA-OURS TOTAL %d" % n)
