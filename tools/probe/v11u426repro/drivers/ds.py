#!/usr/bin/env python3
# ds.py <tag> <casedir>...: downstream verdict per case dir (SLANG_UHDM from the environment);
# run from the worktree root; work under /tmp/v11u426_ds/<tag>/<full key>.
import sys, os
sys.path.insert(0, 'scripts')
import downstream_uhdm2rtlil as ds
tag = sys.argv[1]
for c in sys.argv[2:]:
    c = os.path.abspath(c)
    key = c.split('/tools/probe/')[1].replace('/', '_')
    files = open(os.path.join(c, 'FILES')).read().split() if os.path.isfile(os.path.join(c, 'FILES')) else ['dut.sv']
    parts = ['-parse', '-nobuiltin', '-nocache', '-sv'] + files
    r = ds.one(key, c, parts, '/tmp/v11u426_ds/' + tag, 300)
    print(key, r['verdict'], r['differs'], r['detail'][:80], flush=True)
