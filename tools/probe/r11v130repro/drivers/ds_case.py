# ds_case.py <bin> <workroot> <casedir>...  -> downstream verdict per case with the given binary
import sys, os
os.environ['SLANG_UHDM'] = sys.argv[1]
sys.path.insert(0, '/tmp/wt_v11u130pris/scripts')
import downstream_uhdm2rtlil as ds
for d in sys.argv[3:]:
    d = os.path.realpath(d)
    name = os.path.basename(d)
    r = ds.one(name, d, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], sys.argv[2], 300)
    print(name, r['verdict'], r['differs'], r['surelog_status'], r['slang_status'], r['detail'][:80])
