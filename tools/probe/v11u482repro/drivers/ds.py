import sys, os
sys.path.insert(0, '/tmp/wt_v11u482/scripts')
import downstream_uhdm2rtlil as ds
tag=sys.argv[1]
for c in sys.argv[2:]:
    r = ds.one(os.path.basename(c), c, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u482_ds_'+tag, 300)
    print(tag, c.split('/cases/')[1], r)
