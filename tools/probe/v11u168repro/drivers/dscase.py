import sys, os, glob
sys.path.insert(0, '/tmp/wt_v11u168/scripts')
import downstream_uhdm2rtlil as ds
tag = sys.argv[1]; cases = sys.argv[2:]
for c in cases:
    d = os.path.realpath(c)
    name = d.replace('/tmp/v11u168_cases/', '').replace('/', '_')
    r = ds.one(name, d, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u168_dsw_' + tag, 300)
    print(tag, name, r['verdict'], r['surelog_status'], r['slang_status'], r['surelog_gates'], r['slang_gates'], r['differs'], flush=True)
