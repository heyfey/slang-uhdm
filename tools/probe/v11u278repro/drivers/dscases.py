#!/usr/bin/env python3
# v11u278 dscases.py <label> <workroot> <out.tsv> <case dir>...: the downstream verdict of each case dir with
# the HEAD harness's one() (scripts/downstream_uhdm2rtlil.py), SLANG_UHDM from the environment.  One line per case:
# <case> <verdict> <differs> <surelog_status> <slang_status>.  Fail-closed on $FENCED.
import os, re, sys
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dscases.py: FENCED unset')
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import downstream_uhdm2rtlil as ds
lab, wr, out = sys.argv[1:4]
with open(out, 'w') as fo:
    for d in sys.argv[4:]:
        d = os.path.abspath(d)
        if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', d) for f in F): sys.exit('fenced path refused')
        n = re.sub(r'.*/tools/probe/', '', d).replace('/', '__')
        r = ds.one(n, d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
        fo.write(f"{n} {lab} {r['verdict']} differs={r.get('differs','')} sl={r['surelog_status']} slang={r['slang_status']}\n"); fo.flush()
