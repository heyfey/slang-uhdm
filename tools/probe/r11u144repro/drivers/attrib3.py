#!/usr/bin/env python3
# attrib3.py <law bin> <pristine wd> <out> <row...>: for a row no single switch restores and that is
# byte-deterministic (Earlgrey_0_1), run with ONLY one law on at a time: a law whose lone run keeps the
# pristine bytes contributes nothing to the row's move.
import sys, os, re, subprocess, shlex, hashlib
sys.path.insert(0, '/tmp/wt_r11u144/scripts')
import verify_golden as vg
BIN, P, OUT, rows = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
SW = ['R11U144_SELBAREDEC_OFF', 'R11U144_CALLBITSEL_OFF', 'R11U144_FOLDTSNAME_OFF',
      'R11U144_ELABINST_OFF', 'R11U144_ELABPROP_OFF', 'R11U144_TPPACKEDNET_OFF', 'R11U144_PARAMALIASREF_OFF',
      'R11U144_PKGQUALREF_OFF', 'R11U144_METHQUALSPAN_OFF', 'R11U144_METHATTR_OFF', 'R11U144_DEFGENHP_OFF']
dirs = {'surelog': {k: v[0] for k, v in vg.discover_surelog(None).items()},
        'uhdm2rtlil': {k: v[0] for k, v in vg.discover_uhdm2rtlil(None).items()}}
md5 = lambda p: hashlib.md5(open(p, 'rb').read()).hexdigest()[:12] if os.path.isfile(p) else '-'
fo = open(OUT, 'a')
for row in rows:
    c, mode, name = row.split('/')
    d = [x for x in os.listdir(f'{P}/{c}/{mode}') if re.match(re.escape(name) + r'-[0-9a-f]{8}$', x)][0]
    d = f'{P}/{c}/{mode}/{d}'
    argv = shlex.split([l for l in open(d + '/cmds.txt') if l.startswith('slang:')][0].split(None, 1)[1])[1:]
    i = argv.index('-o'); argv = argv[:i] + argv[i + 2:]
    pm = md5(d + '/slang.uhdm'); contrib = []
    for sw in SW:
        o = f'/tmp/r11u144_scr/at3_{os.getpid()}.uhdm'
        if os.path.exists(o): os.remove(o)
        env = dict(os.environ); env.update({s: '1' for s in SW if s != sw})
        subprocess.run([BIN] + argv + ['-o', o], cwd=dirs[c][name], env=env, capture_output=True, timeout=3600)
        if md5(o) != pm: contrib.append(sw.replace('R11U144_', '').replace('_OFF', ''))
        os.remove(o)
    fo.write(f'{row}\tlaws whose lone run moves the bytes: {" ".join(contrib)}\n'); fo.flush()
