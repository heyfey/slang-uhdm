import sys, os
# usage: ds.py <label> <workroot> <casedir>...   (SLANG_UHDM must be exported)
sys.path.insert(0, '/tmp/wt_v11u158/scripts')
os.chdir('/tmp/wt_v11u158')
import downstream_uhdm2rtlil as ds
lab, wr = sys.argv[1], sys.argv[2]
for c in sys.argv[3:]:
    c = os.path.abspath(c)
    name = c.replace('/tmp/v11u158_cases/', '').replace('/', '_')
    r = ds.one(name, c, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], wr, 300)
    print(lab, name, r['verdict'], r.get('differs',''), r.get('detail','')[:80], flush=True)
