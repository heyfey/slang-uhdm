import sys, os
sys.path.insert(0, '/tmp/wt_v11u163/scripts')
import downstream_uhdm2rtlil as ds
fenced = os.environ.get('FENCED','').split()
assert fenced, 'no FENCED'
tag = sys.argv[1]
for c in sys.argv[2:]:
    c = os.path.abspath(c)
    assert not any(f in c for f in fenced)
    name = c.replace('/tmp/v11u163_cases/','').replace('/','_')
    r = ds.one(name, c, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], f'/tmp/v11u163_dsw_{tag}', 300)
    print(tag, name, r['verdict'], r['surelog_status'], r['slang_status'], r['surelog_gates'], r['slang_gates'], r['differs'], r['detail'][:80], flush=True)
