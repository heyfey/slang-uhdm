#!/usr/bin/env python3
# attrib2.py <law bin> <pristine wd> <evidence dir> <row...>: for rows no single switch restores:
# (a) the order-blind uhdm-dump diff of pristine vs law-with-R11U144_OFF (0 lines = the UVM order coin);
# (b) per law, the order-blind diff line count of pristine vs a run where ONLY that law is on.
import sys, os, re, subprocess, shlex
sys.path.insert(0, '/tmp/wt_r11u144/scripts')
import verify_golden as vg
BIN, P, E, rows = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
SW = ['R11U144_SELBAREDEC_OFF', 'R11U144_CALLBITSEL_OFF', 'R11U144_FOLDTSNAME_OFF',
      'R11U144_ELABINST_OFF', 'R11U144_ELABPROP_OFF', 'R11U144_TPPACKEDNET_OFF', 'R11U144_PARAMALIASREF_OFF',
      'R11U144_PKGQUALREF_OFF', 'R11U144_METHQUALSPAN_OFF', 'R11U144_METHATTR_OFF', 'R11U144_DEFGENHP_OFF']
DUMP = os.environ['UHDM_DUMP']
dirs = {'surelog': {k: v[0] for k, v in vg.discover_surelog(None).items()},
        'uhdm2rtlil': {k: v[0] for k, v in vg.discover_uhdm2rtlil(None).items()}}
def sdump(p, strip):
    t = subprocess.run([DUMP, p], capture_output=True, text=True, timeout=1800).stdout.replace(strip, '')
    t = re.sub(r'/tmp/r11u144_scr/at2_[0-9]+', '', t)
    return sorted(t.split('\n'))
def odiff(a, b):
    import collections
    ca, cb = collections.Counter(a), collections.Counter(b)
    return sum(((ca - cb) + (cb - ca)).values())
out = open(E + '/attribution_multi.txt', 'a')
for row in rows:
    c, mode, name = row.split('/')
    d = [x for x in os.listdir(f'{P}/{c}/{mode}') if re.match(re.escape(name) + r'-[0-9a-f]{8}$', x)][0]
    d = f'{P}/{c}/{mode}/{d}'
    argv = shlex.split([l for l in open(d + '/cmds.txt') if l.startswith('slang:')][0].split(None, 1)[1])[1:]
    i = argv.index('-o'); argv = argv[:i] + argv[i + 2:]
    base = sdump(d + '/slang.uhdm', d)
    def run(envs):
        o = f'/tmp/r11u144_scr/at2_{os.getpid()}.uhdm'
        if os.path.exists(o): os.remove(o)
        env = dict(os.environ); env.update(envs)
        subprocess.run([BIN] + argv + ['-o', o], cwd=dirs[c][name], env=env, capture_output=True, timeout=1800)
        r = sdump(o, os.path.dirname(o)); os.remove(o); return r
    res = [f'OFF:{odiff(base, run({"R11U144_OFF": "1"}))}']
    for sw in SW:
        only = {s: '1' for s in SW if s != sw}
        res.append(f'{sw.replace("R11U144_","").replace("_OFF","")}:{odiff(base, run(only))}')
    out.write(f'{row}\t' + ' '.join(res) + '\n'); out.flush()
    print(row, ' '.join(res))
