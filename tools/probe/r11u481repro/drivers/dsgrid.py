import sys, os, importlib
sys.path.insert(0, '/tmp/wt_r11u481/scripts')
binary, tag = sys.argv[1], sys.argv[2]
os.environ['SLANG_UHDM'] = binary
import verify_golden as vg
importlib.reload(vg)
import downstream_uhdm2rtlil as ds
importlib.reload(ds)
for d in sys.argv[3:]:
    d = os.path.abspath(d)
    name = 'r11u481_' + tag + '_' + d.replace('/', '_')[-40:]
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/r11u481_ds', 300)
    print(d.split('/cases/')[-1], tag, r[:3] if isinstance(r, (list, tuple)) else r, flush=True)
