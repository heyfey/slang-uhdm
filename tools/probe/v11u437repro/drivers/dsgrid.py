import sys, os
sys.path.insert(0, '/tmp/wt_v11u437/scripts')
import downstream_uhdm2rtlil as ds
binname, work = sys.argv[1], sys.argv[2]
for c in sys.argv[3:]:
    d = os.path.abspath(c)
    r = ds.one(c.replace('/', '_'), d, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], work, 300)
    print(binname, c, r, flush=True)
