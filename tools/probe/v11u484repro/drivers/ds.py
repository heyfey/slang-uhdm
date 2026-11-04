import sys,os
sys.path.insert(0,'/tmp/wt_v11u484/scripts')
import downstream_uhdm2rtlil as ds
tag=sys.argv[1]; wr=f'/tmp/v11u484_ds_{tag}'; os.makedirs(wr,exist_ok=True)
for d in sys.argv[2:]:
    name=d.replace('/tmp/wt_v11u484/tools/probe/','').replace('/','_')
    r=ds.one(name,d,['-parse','-nobuiltin','-nocache','-sv','dut.sv'],wr,300)
    print(tag,d.replace('/tmp/wt_v11u484/tools/probe/',''),r,flush=True)
