import sys, os
sys.path.insert(0,'/tmp/wt_v11u130pris/scripts')
import verify_golden as vg
corp,name=sys.argv[1],sys.argv[2]
t=(vg.discover_surelog if corp=='surelog' else vg.discover_uhdm2rtlil)('^'+name+'$')
print(t[name][0])
