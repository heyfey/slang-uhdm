#!/usr/bin/env python3
# ds.py <tag> <case dirs...>: the downstream verdict of each case (scripts/downstream_uhdm2rtlil.one: uhdm2rtlil's own
# Surelog lane vs the slang lane under $SLANG_UHDM, Yosys through the plugin, nohier/il/synth byte comparison).
# Run with a fresh GOLDEN_CACHE (cases are edited in place during a pass; the cache keys on directory + arguments).
import sys, os
sys.path.insert(0, '/tmp/wt_r11u149/scripts')
import downstream_uhdm2rtlil as ds
tag = sys.argv[1]
for d in sys.argv[2:]:
    c = os.path.basename(os.path.dirname(d)) + '__' + os.path.basename(d)
    r = ds.one(c, d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/r11u149_dsw_' + tag, 300)
    print(tag, c, r['verdict'], r['surelog_status'], r['slang_status'], r['differs'] or '-', (r['detail'] or '-')[:60], sep='\t', flush=True)
