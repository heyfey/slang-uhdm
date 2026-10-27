import sys, os, glob
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
import downstream_uhdm2rtlil as ds
label = sys.argv[1]; work = sys.argv[2]; cases = sys.argv[3:]
for c in cases:
    d = os.path.abspath(c)
    src = open(os.path.join(d, 'dut.sv')).read()
    if 'class ' in src or 'program ' in src or 'interface ' in src:
        continue
    key = os.path.basename(os.path.dirname(d)) + '/' + os.path.basename(d)
    r = ds.one(key.replace('/', '_'), d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], work, 300)
    print(label, key, r if not isinstance(r, dict) else {k: r[k] for k in ('verdict', 'differs') if k in r}, flush=True)
