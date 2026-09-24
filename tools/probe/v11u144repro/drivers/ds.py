import sys, os
sys.path.insert(0, '/tmp/wt_v11u144/scripts')
import downstream_uhdm2rtlil as ds
tag = sys.argv[1]
for c in sys.argv[2:]:
    d = '/tmp/v11u144_cases/' + c
    r = ds.one(c.replace('/', '_'), d, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u144_dsw_' + tag, 300)
    print(tag, c, r['verdict'], r['surelog_status'], r['slang_status'], r['differs'], r['detail'][:80])
