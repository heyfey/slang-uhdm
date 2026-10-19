import sys, os, glob
sys.path.insert(0, '/tmp/wt_v11u409/scripts')
os.environ['GOLDEN_CACHE'] = '/tmp/v11u409_dsgold'
import downstream_uhdm2rtlil as ds
bins = {'pris': '/tmp/v11u409_bin/pristine', 'law': '/tmp/v11u409_bin/law', 'ver': sys.argv[1]}
out = open(sys.argv[2], 'w')
cases = sorted(glob.glob('/tmp/wt_v11u409/tools/probe/v11u409repro/cases/*/*')) + sorted(glob.glob('/tmp/wt_v11u409/tools/probe/r11u409repro/cases/GV/*'))
for c in cases:
    name = c.split('/cases/')[1].replace('/', '_')
    res = []
    for k, b in bins.items():
        os.environ['SLANG_UHDM'] = b
        r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/v11u409_dsw/' + k, 300)
        res.append(f"{k}={r['verdict']}:{r['differs']}")
    out.write(name + ' ' + ' '.join(res) + '\n'); out.flush()
out.write('DONE\n')
