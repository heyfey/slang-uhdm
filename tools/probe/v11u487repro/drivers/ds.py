# ds.py <workroot> <casedir>...: downstream verdict per case dir (SLANG_UHDM = the binary under test)
import sys,os
sys.path.insert(0,'/tmp/wt_v11u487/scripts')
import downstream_uhdm2rtlil as ds
wr=sys.argv[1]
for case in sys.argv[2:]:
    case=os.path.realpath(case)
    name=case.split('/cases/')[1].replace('/','_')
    r=ds.one(name, case, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], wr, 300)
    print(case.split('/cases/')[1], r, flush=True)
