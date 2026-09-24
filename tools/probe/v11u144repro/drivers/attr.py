import sys, os, re, subprocess, hashlib, shlex
sys.path.insert(0, '/tmp/wt_v11u144/scripts')
import verify_golden as vg
from concurrent.futures import ThreadPoolExecutor
BIN = '/tmp/v11u144_bin/law.bin'; P = '/tmp/v11u144_wdP'; L = '/tmp/v11u144_wdL'
SW = ['R11U144_OFF', 'R11U144_SELBAREDEC_OFF', 'R11U144_CALLBITSEL_OFF', 'R11U144_FOLDTSNAME_OFF',
      'R11U144_ELABINST_OFF', 'R11U144_ELABPROP_OFF', 'R11U144_TPPACKEDNET_OFF', 'R11U144_PARAMALIASREF_OFF',
      'R11U144_PKGQUALREF_OFF', 'R11U144_METHQUALSPAN_OFF', 'R11U144_METHATTR_OFF', 'R11U144_DEFGENHP_OFF']
skip = set(sys.argv[1:])
dirs = {'surelog': {k: v[0] for k, v in vg.discover_surelog(None).items()},
        'uhdm2rtlil': {k: v[0] for k, v in vg.discover_uhdm2rtlil(None).items()}}
md5 = lambda p: hashlib.md5(open(p, 'rb').read()).hexdigest()[:12] if os.path.isfile(p) else '-'
tasks = []
for c in ('surelog', 'uhdm2rtlil'):
    for ln in open(f'/tmp/v11u144_bv_{c}.txt'):
        m = re.match(r'MOVER \./(\w+)/(.+)-([0-9a-f]{8})/slang.uhdm', ln)
        if not m: continue
        mode, name = m.group(1), m.group(2)
        if name in skip: continue
        d = f'{P}/{c}/{mode}/{name}-{m.group(3)}'; dl = f'{L}/{c}/{mode}/{name}-{m.group(3)}'
        cmd = [l for l in open(dl + '/cmds.txt') if l.startswith('slang:')][0].split(None, 1)[1]
        argv = shlex.split(cmd)
        assert argv[0] == BIN, argv[0]
        argv = argv[1:]; i = argv.index('-o'); argv = argv[:i] + argv[i + 2:]
        for sw in SW: tasks.append((c, mode, name, d, argv, sw))
def run(t):
    c, mode, name, d, argv, sw = t
    o = f'/tmp/v11u144_attr/{c}_{mode}_{name}_{sw}.uhdm'
    if os.path.exists(o): os.remove(o)
    env = dict(os.environ); env[sw] = '1'
    r = subprocess.run([BIN] + argv + ['-o', o], cwd=dirs[c][name], env=env, capture_output=True, timeout=1800)
    ok = md5(o) == md5(d + '/slang.uhdm'); lw = md5(o) == md5(d.replace(P, L) + '/slang.uhdm')
    res = (f'{c}/{mode}/{name}', sw, r.returncode, 'PRISTINE' if ok else ('LAW' if lw else 'OTHER'))
    if os.path.exists(o) and (ok or lw): os.remove(o)
    return res
os.makedirs('/tmp/v11u144_attr', exist_ok=True)
with ThreadPoolExecutor(3) as ex:
    for r in ex.map(run, tasks): print(*r, flush=True)
