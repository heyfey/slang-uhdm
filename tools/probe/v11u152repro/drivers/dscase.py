#!/usr/bin/env python3
# dscase.py <binary> <tag> <casedir>... : downstream verdict per case (surelog lane vs slang lane)
import sys,os
os.environ['SLANG_UHDM']=sys.argv[1]
sys.path.insert(0,'/tmp/wt_v11u152/scripts')
import downstream_uhdm2rtlil as ds
tag=sys.argv[2]
for d in sys.argv[3:]:
    rel=d.split('/cases/')[-1].split('/v11u152_cases/')[-1]
    w='/tmp/v11u152_dsc/'+tag+'/'+rel.replace('/','__')
    os.makedirs(w,exist_ok=True)
    r=ds.one(rel.replace('/','__'), d, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], w, 300)
    print(tag, rel, ','.join(str(v) for v in r.values()), flush=True)
