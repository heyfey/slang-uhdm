import sys, os, glob
sys.path.insert(0, '/tmp/wt_v11u406/scripts')
import downstream_uhdm2rtlil as ds
root, work, glb = sys.argv[1], sys.argv[2], sys.argv[3]
for d in sorted(glob.glob(os.path.join(root, glb))):
    src = open(os.path.join(d, 'dut.sv')).read()
    if 'class ' in src: continue
    parts = ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv']
    if '\nmodule top' in src: parts += ['-top', 'top']
    name = d[len(root)+1:].replace('/', '_')
    r = ds.one(name, d, parts, work, 300)
    print(name, r['verdict'], r['differs'], r['detail'][:80], flush=True)
