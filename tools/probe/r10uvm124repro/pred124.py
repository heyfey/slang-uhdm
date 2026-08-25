#!/usr/bin/env python3
"""r10uvm124 — the A-PRIORI mover predictor: reads ONE PRISTINE dump and names
every cell § selRecvStmtCallBareNames124 can touch, BEFORE any comparison with
golden and without ever looking at the patched binary.

A cell is a candidate when the pristine database holds a `method_func_call`
whose `vpiPrefix` object's VpiName carries a `[`, or whose OWN VpiName does.
That is the whole written surface of the law (it renames a select-spelled
statement-call receiver, and the call itself, to the bare base name Surelog's
`CompileHelper::compileTfCall` reads off the NAME NODES).  It is a deliberate
OVER-approximation: it ignores the tree check
(`builtinRecvStepSelectors74` must confirm the text split component-for-
component and dimension-for-dimension) and the statement/expression split, so
every database the law can touch is named, and a named database that does NOT
move is a fence doing its job.

  usage: pred124.py <pristine-dump> [label]

Prints one line per candidate cell, and a `CANDIDATES=<n>` line ONLY when
`n > 0`.  A database with nothing to predict prints NOTHING — the sweep counts
the silent ones and asserts the total, and an artifact that enumerated every
row of the workdir by name would spell test names this campaign never spells.
"""
import subprocess, sys, os

HERE = os.path.dirname(os.path.abspath(__file__))
label = sys.argv[2] if len(sys.argv) > 2 else sys.argv[1]
n = 0
out = subprocess.run(['python3', os.path.join(HERE, 'cells124.py'), sys.argv[1]],
                     capture_output=True, text=True)
for line in out.stdout.split('\n'):
    if not line.strip():
        continue
    f = line.split('\t')
    if len(f) < 3:
        continue
    val = f[2]
    mfcname = val.split('mfc=', 1)[1].split('@')[0]
    pfx = val.split('pfx=', 1)[1]
    pfxname = pfx.split('|')[1] if pfx != '<none>' else ''
    if '[' in mfcname or '[' in pfxname:
        print('%s\t%s\t%s' % (label, f[1], val))
        n += 1
if n or out.returncode != 0:
    print('CANDIDATES=%d\t%s\trc=%d' % (n, label, out.returncode))
