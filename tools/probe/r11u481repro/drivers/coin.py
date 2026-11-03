import os, sys, json, csv, subprocess, hashlib
sys.path.insert(0, '/tmp/wt_r11u481/scripts/svtests')
import svtests_matrix as sm
SVT = '/home/heyfey/git-repos/sv-tests'
rel = sys.argv[1]
libs = json.load(open(os.path.join(SVT, 'conf', 'runners', 'libs.json')))
d = '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0'
libs['uvm'] = {'files': [os.path.join(d, 'src', 'uvm_pkg.sv')], 'incdirs': [os.path.join(d, 'src')]}
sv = os.path.join(SVT, 'tests', rel)
params = sm.parse_metadata(sv); sm.apply_libs(params, libs, os.path.join(SVT, 'third_party'))
tags = params['tags']
args = (['--sverilog'] if any(t in tags for t in ('black-parrot', 'basejump', 'ivtest')) else [])
top = params['top_module'].strip()
if top: args += ['--top', top]
args += ['-D' + x for x in params['defines']] + ['-I' + x for x in params['incdirs']] + params['files'] + ['--single-unit']
wd = '/tmp/r11u481_coin'; os.makedirs(wd, exist_ok=True)
for b in sys.argv[2:]:
    for k in range(3):
        o = f'{wd}/o.uhdm'
        if os.path.exists(o): os.remove(o)
        r = subprocess.run([b] + args + ['-o', o], cwd=wd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode
        print(os.path.basename(b), k, r, hashlib.md5(open(o,'rb').read()).hexdigest()[:10])
