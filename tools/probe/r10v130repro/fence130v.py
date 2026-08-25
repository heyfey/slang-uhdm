#!/usr/bin/env python3
# r10v130repro/fence130v.py — THE VERIFIER'S OWN FENCE, written INDEPENDENTLY of
# r10uvm130repro/fence130.sh so a shared bug cannot hide in both.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   fence130v.py <sweep workdir> <ct130cen path> <out.tsv>
#
# Per test it censuses BOTH databases and reports, keyed on (module fullname,
# implicit-net NAME) — a key both producers spell and which no span can perturb:
#   HIT     golden owns an IMPLICIT wire of that name in that module, WE own
#           none, and our own database carries an UNBOUND reference of that name
#           whose CTX is NEWARG and whose parent is not a hier_path.
#   OTHER   golden owns an implicit wire we lack, but no such NEWARG reference.
#   MIRROR  WE own an implicit wire of a name golden does not — a WIDENING.
import sys, os, subprocess, collections

W, CEN, OUT = sys.argv[1], sys.argv[2], sys.argv[3]

def census(db, tag):
    try:
        r = subprocess.run([CEN, db, tag], capture_output=True, text=True, timeout=900)
    except Exception:
        return None
    if r.returncode != 0:
        return None
    return r.stdout.splitlines()

def parse(lines):
    impl = collections.defaultdict(set)     # module -> {name}
    newarg_unbound = set()                  # {name}
    for ln in lines:
        f = ln.split('\t')
        if len(f) < 3: continue
        if f[1] == 'NET' and f[3] == 'IMPL':
            impl[f[4]].add(f[6])
        elif f[1] == 'REF' and len(f) >= 15:
            if f[14] == 'NEWARG' and f[10] != 'hier_path' and f[8] == 'NONE':
                newarg_unbound.add(f[7])
    return impl, newarg_unbound

def golden_of(cmds):
    txt = open(cmds, encoding='utf-8', errors='replace').read()
    import re
    m = re.search(r'(/\S*golden\.uhdm)', txt)
    if m: return m.group(1)
    m = re.search(r'(/\S*slang-uhdm-goldens/[0-9a-f]+)', txt)
    if m: return m.group(1).rstrip(')') + '/golden.uhdm'
    return None

tests = skip = 0
hit = other = mirror = 0
rows = []
movers = set()
for mode in sorted(os.listdir(W)):
    md = os.path.join(W, mode)
    if not os.path.isdir(md): continue
    for name in sorted(os.listdir(md)):
        d = os.path.join(md, name)
        c, o = os.path.join(d, 'cmds.txt'), os.path.join(d, 'slang.uhdm')
        if not (os.path.isfile(c) and os.path.isfile(o)): skip += 1; continue
        g = golden_of(c)
        if not g or not os.path.isfile(g): skip += 1; continue
        gl, ol = census(g, 'G'), census(o, 'O')
        if gl is None or ol is None: skip += 1; continue
        tests += 1
        gi, _ = parse(gl); oi, onew = parse(ol)
        for mod, names in gi.items():
            for n in sorted(names - oi.get(mod, set())):
                if n in onew:
                    hit += 1; rows.append(f"HIT\t{mode}\t{name}\t{mod}\t{n}"); movers.add(f"{mode}/{name}")
                else:
                    other += 1; rows.append(f"OTHER\t{mode}\t{name}\t{mod}\t{n}")
        for mod, names in oi.items():
            for n in sorted(names - gi.get(mod, set())):
                mirror += 1; rows.append(f"MIRROR\t{mode}\t{name}\t{mod}\t{n}")
open(OUT, 'w').write('\n'.join(rows) + ('\n' if rows else ''))
print(f"measured={tests} skip={skip} HIT={hit} OTHER={other} MIRROR={mirror}")
print("DATABASES THAT MUST MOVE (%d): %s" % (len(movers), ' '.join(sorted(movers))))
