import sys, os
sys.path.insert(0, '/tmp/wt_v11u485/scripts')
import downstream_uhdm2rtlil as ds
tag = sys.argv[1]
for c in sys.argv[2:]:
    d = os.path.realpath(c)
    files = open(d + '/FILES').read().split() if os.path.exists(d + '/FILES') else ['dut.sv']
    name = c.replace('/', '_')
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv'] + files, '/tmp/v11u485_dsw_' + tag, 300)
    print(c, r['verdict'], r['differs'], r['detail'][:60])
