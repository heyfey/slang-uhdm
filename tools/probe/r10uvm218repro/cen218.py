#!/usr/bin/env python3
# r10uvm218 — THE REFERENCE-ACTUAL CENSUS.  MEASUREMENT ONLY; the official
# uhdm-cmp is the sole acceptance judge and it never scores anything here.
#
# For every `ref_obj` / `ref_var` in a uhdm-dump whose vpiFullName starts with a
# given PREFIX, record (vpiName, line, col) -> the KIND of its vpiActual (or '-'
# when it has none), as a MULTISET per key (the same source position is emitted
# once per copy of the enclosing listing, and a last-writer dict would drop
# rows — RESUME §9's census trap).
#
# Then join golden (LHS, ALWAYS Surelog) against ours (RHS, ALWAYS slang-uhdm)
# and classify every key:
#   SAME          the two multisets are equal
#   MISSING-OURS  golden has at least one actual here, ours has none
#   EXTRA-OURS    ours has at least one actual here, golden has none
#   OTHER         both sides carry actuals but the multisets differ, or the key
#                 exists on one side only (a naming/shape residue, not a bind)
#
#   usage: cen218.py <golden.dump> <ours.dump> <fullname-prefix> [--quiet]
#
# GUARDS: a missing input is FATAL (a scorer that reads nothing must never
# print perfection); `grep`-free so no zero-match exit kills a caller's chain.
import sys, re, collections, os

def scan(path, pre):
    if not os.path.isfile(path):
        sys.exit("FATAL: no dump at %s" % path)
    out = []
    lines = open(path, errors='replace').read().split('\n')
    n = len(lines)
    for i, l in enumerate(lines):
        m = re.match(r'^(\s*)\\_(ref_obj|ref_var): \(([^)]*)\), line:(\d+):(\d+)', l)
        if not m:
            continue
        ind, fn, ln, col = m.group(1), m.group(3), int(m.group(4)), int(m.group(5))
        if not fn.startswith(pre):
            continue
        child = ind + '  |'
        childobj = ind + '  \\_'
        deeper = ind + '    '
        act = None
        nm = None
        j = i + 1
        while j < n:
            lj = lines[j]
            if not (lj.startswith(child) or lj.startswith(childobj) or
                    lj.startswith(deeper)):
                break
            if lj.startswith(child + 'vpiName:'):
                nm = lj.split('vpiName:', 1)[1]
            if lj.startswith(child + 'vpiActual'):
                mk = re.match(r'^\s*\\_(\w+):', lines[j + 1]) if j + 1 < n else None
                act = mk.group(1) if mk else '?'
            j += 1
        out.append(((nm, ln, col), act))
    return out

def main():
    if len(sys.argv) < 4:
        sys.exit("usage: cen218.py <golden.dump> <ours.dump> <prefix> [--quiet]")
    quiet = '--quiet' in sys.argv[4:]
    g = scan(sys.argv[1], sys.argv[3])
    o = scan(sys.argv[2], sys.argv[3])
    gm = collections.defaultdict(list)
    om = collections.defaultdict(list)
    for k, a in g:
        gm[k].append(a)
    for k, a in o:
        om[k].append(a)
    keys = sorted(set(gm) | set(om), key=lambda k: (k[1], k[2], str(k[0])))
    same = miss = extra = other = 0
    for k in keys:
        gv = sorted(x or '-' for x in gm.get(k, []))
        ov = sorted(x or '-' for x in om.get(k, []))
        if gv == ov:
            same += 1
            tag = 'SAME'
        else:
            gs = set(x for x in gv if x != '-')
            os_ = set(x for x in ov if x != '-')
            if gs and not os_:
                miss += 1; tag = 'MISSING-OURS'
            elif os_ and not gs:
                extra += 1; tag = 'EXTRA-OURS'
            else:
                other += 1; tag = 'OTHER'
        if not quiet and tag != 'SAME':
            print("%-13s %-22s %4d:%-3d g=%s o=%s" %
                  (tag, str(k[0]), k[1], k[2], gv, ov))
    print("-- REFS golden=%d ours=%d  KEYS=%d  SAME=%d MISSING-OURS=%d "
          "EXTRA-OURS=%d OTHER=%d" %
          (len(g), len(o), len(keys), same, miss, extra, other))

main()
