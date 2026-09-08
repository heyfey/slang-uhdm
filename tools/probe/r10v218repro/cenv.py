#!/usr/bin/env python3
# r10v218 — the VERIFIER'S OWN reference-actual census.  MEASUREMENT ONLY.
# Unlike the pass's cen218.py this records the vpiActual's KIND **AND ITS NAME
# AND LINE**, so a reference bound to an object of the RIGHT KIND but the WRONG
# TARGET (two functions with the same formal name) is visible.
# usage: cenv.py <golden.dump> <ours.dump> <prefix> [--quiet]
import sys, re, collections, os

def scan(path, pre):
    if not os.path.isfile(path):
        sys.exit("FATAL: no dump at %s" % path)
    lines = open(path, errors='replace').read().split('\n')
    n = len(lines); out = []
    for i, l in enumerate(lines):
        m = re.match(r'^(\s*)\\_(ref_obj|ref_var): \(([^)]*)\), line:(\d+):(\d+)', l)
        if not m:
            continue
        ind, fn, ln, col = m.group(1), m.group(3), int(m.group(4)), int(m.group(5))
        if not fn.startswith(pre):
            continue
        child = ind + '  |'; childobj = ind + '  \\_'; deeper = ind + '    '
        act = None; nm = None
        j = i + 1
        while j < n:
            lj = lines[j]
            if not (lj.startswith(child) or lj.startswith(childobj) or
                    lj.startswith(deeper)):
                break
            if lj.startswith(child + 'vpiName:'):
                nm = lj.split('vpiName:', 1)[1]
            if lj.startswith(child + 'vpiActual'):
                if j + 1 < n:
                    mk = re.match(r'^\s*\\_(\w+): \(([^)]*)\), line:(\d+):(\d+)', lines[j+1])
                    if mk:
                        act = "%s(%s)@%s:%s" % (mk.group(1), mk.group(2),
                                                mk.group(3), mk.group(4))
                    else:
                        mk2 = re.match(r'^\s*\\_(\w+):', lines[j+1])
                        act = mk2.group(1) if mk2 else '?'
                else:
                    act = '?'
            j += 1
        out.append(((nm, ln, col), act))
    return out

def main():
    quiet = '--quiet' in sys.argv[4:]
    g = scan(sys.argv[1], sys.argv[3]); o = scan(sys.argv[2], sys.argv[3])
    gm = collections.defaultdict(list); om = collections.defaultdict(list)
    for k, a in g: gm[k].append(a)
    for k, a in o: om[k].append(a)
    keys = sorted(set(gm) | set(om), key=lambda k: (k[1], k[2], str(k[0])))
    same = miss = extra = other = 0
    for k in keys:
        gv = sorted(x or '-' for x in gm.get(k, []))
        ov = sorted(x or '-' for x in om.get(k, []))
        if gv == ov:
            same += 1; tag = 'SAME'
        else:
            gs = set(x for x in gv if x != '-'); os_ = set(x for x in ov if x != '-')
            if gs and not os_: miss += 1; tag = 'MISSING-OURS'
            elif os_ and not gs: extra += 1; tag = 'EXTRA-OURS'
            else: other += 1; tag = 'OTHER'
        if not quiet and tag != 'SAME':
            print("%-13s %-22s %4d:%-3d g=%s o=%s" % (tag, str(k[0]), k[1], k[2], gv, ov))
    print("-- REFS golden=%d ours=%d  KEYS=%d  SAME=%d MISSING-OURS=%d "
          "EXTRA-OURS=%d OTHER=%d" % (len(g), len(o), len(keys), same, miss, extra, other))
main()
