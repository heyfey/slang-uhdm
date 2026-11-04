import sys,os
sys.path.insert(0,'/tmp/wt_r11u487/scripts')
import downstream_uhdm2rtlil as ds
case=sys.argv[1]; wr=sys.argv[2]
print(case, ds.one(os.path.basename(case.rstrip('/')), case, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], wr, 300))
