import sys, os
sys.path.insert(0, '/tmp/wt_v11u140/scripts')
import downstream_uhdm2rtlil as ds
for c in sys.argv[1:]:
    c = os.path.realpath(c)
    r = ds.one(os.path.basename(c), c, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u140_dsw_' + os.environ['TAG'], 300)
    print(os.path.basename(c), r)
