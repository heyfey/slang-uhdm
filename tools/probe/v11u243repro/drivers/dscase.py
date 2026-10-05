#!/usr/bin/env python3
# (v11u243: copied from r11u243repro/drivers) dscase.py <binary> <tag> <trace dir>: every case under cases/ through the downstream harness's own `one`
# (scripts/downstream_uhdm2rtlil.py: the Surelog lane with uhdm2rtlil's Surelog and the downstream flags, the slang
# lane with the translated command line -DSYNTHESIS dut.sv --single-unit --nobuiltin), the binary under test as
# SLANG_UHDM, R11U243_TRACE set (the positive control of the downstream-lane census). One line per case: verdict and
# the differing files. Cases only (no corpus path is read); fail-closed on $FENCED.
import os, sys, glob
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dscase.py: source drivers/env.sh first')
H = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
R = os.path.abspath(os.path.join(H, '..', '..', '..'))
BIN, TAG, TR = sys.argv[1:4]
os.environ['SLANG_UHDM'] = BIN; os.environ['R11U243_TRACE'] = TR; os.makedirs(TR, exist_ok=True)
sys.path.insert(0, os.path.join(R, 'scripts'))
import downstream_uhdm2rtlil as ds
wr = os.path.join(os.environ['S'], 'dscase_' + TAG)
for c in sorted(glob.glob(os.path.join(H, 'cases', '*', '*'))):
    if any(f in c for f in F): sys.exit('fenced path refused')
    name = os.path.relpath(c, os.path.join(H, 'cases')).replace('/', '_')
    print(name, ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300), flush=True)
