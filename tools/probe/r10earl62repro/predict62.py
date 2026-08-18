#!/usr/bin/env python3
"""r10earl62 — PREDICT THE MOVER SET BY NAME, from PRISTINE databases only.

§ defBodyTypedefSiteShare62 can only move a test in which ONE module
definition is elaborated into MORE THAN ONE body and the specialization that
produced the def listing is not the only one — the pristine signature of that
is a split inside ONE (defname, signal) or ONE (defname, cont_assign, path,
ref name) key: some copies carry the named struct/enum typespec (or the
enum_const / typespec_member Actual) and the others carry the bare
logic_typespec (or no Actual at all).

Reads only the pristine .uhdm databases a sweep left behind — no rebuild, no
golden, no judgement.  MEASUREMENT ONLY.

  usage: predict62.py <mlts62> <cacen62> <workdir-root> [workdir-root ...]
"""
import subprocess, sys, os, collections

MLTS, CACEN = sys.argv[1], sys.argv[2]
roots = sys.argv[3:]
hits = []
n = 0
for root in roots:
    for dirpath, dirnames, filenames in os.walk(root):
        if 'slang.uhdm' not in filenames:
            continue
        db = os.path.join(dirpath, 'slang.uhdm')
        n += 1
        why = []
        try:
            out = subprocess.run([MLTS, db], capture_output=True, text=True,
                                 timeout=300).stdout
        except Exception:
            out = ''
        kinds = collections.defaultdict(set)
        for l in out.splitlines():
            f = l.split()
            if len(f) < 7 or f[0] != 'TS' or f[4] not in ('VAR', 'NET'):
                continue
            defn = f[3]          # VpiDefName: the DEFINITION, shared by every
                                 # instance -- the grouping the law is about
            ts = f[5]
            nm = f[-1]
            kinds[(defn, f[4], nm)].add(ts)
        for k, v in kinds.items():
            if len(v) > 1 and any(x.startswith('logic_typespec:') and
                                  x.endswith(':') for x in v) and \
               any(x.startswith(('struct_typespec:', 'enum_typespec:',
                                 'union_typespec:', 'array_typespec:'))
                   for x in v):
                why.append('TS %s/%s/%s %s' % (k[0], k[1], k[2], sorted(v)))
        try:
            out2 = subprocess.run([CACEN, db], capture_output=True, text=True,
                                  timeout=300).stdout
        except Exception:
            out2 = ''
        acts = collections.defaultdict(set)
        for l in out2.splitlines():
            if not l.startswith('CA ELAB'):
                continue
            key, _, val = l.rstrip().partition(' = ')
            acts[key].add(val)
        for k, v in acts.items():
            if '-()' in v and any(x.startswith(('enum_const(', 'typespec_member('))
                                  for x in v):
                why.append('REF %s %s' % (k, sorted(v)))
        if why:
            hits.append((os.path.relpath(db, root), why))
print('scanned %d databases; %d PREDICTED MOVERS' % (n, len(hits)))
for name, why in sorted(hits):
    print('  %s' % name)
    for w in why[:4]:
        print('      %s' % w[:150])
