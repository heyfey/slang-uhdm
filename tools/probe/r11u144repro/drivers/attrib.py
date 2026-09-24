#!/usr/bin/env python3
# attrib.py <law bin> <pristine wd> <evidence dir>: re-run every byte mover's recorded slang-uhdm command
# (cmds.txt, in the test's own directory) with the law binary under R11U144_OFF=1 and under each single
# switch; print the switches whose run gives back the PRISTINE bytes.
import sys, os, re, subprocess, hashlib, shlex
sys.path.insert(0, '/tmp/wt_r11u144/scripts')
import verify_golden as vg
BIN, P, E = sys.argv[1], sys.argv[2], sys.argv[3]
SW = ['R11U144_OFF', 'R11U144_SELBAREDEC_OFF', 'R11U144_CALLBITSEL_OFF', 'R11U144_FOLDTSNAME_OFF',
      'R11U144_ELABINST_OFF', 'R11U144_ELABPROP_OFF', 'R11U144_TPPACKEDNET_OFF', 'R11U144_PARAMALIASREF_OFF',
      'R11U144_PKGQUALREF_OFF', 'R11U144_METHQUALSPAN_OFF', 'R11U144_METHATTR_OFF', 'R11U144_DEFGENHP_OFF']
dirs = {'surelog': {k: v[0] for k, v in vg.discover_surelog(None).items()},
        'uhdm2rtlil': {k: v[0] for k, v in vg.discover_uhdm2rtlil(None).items()}}
md5 = lambda p: hashlib.md5(open(p, 'rb').read()).hexdigest()[:12] if os.path.isfile(p) else '-'
out = open(E + '/attribution.txt', 'w')
for c in ('surelog', 'uhdm2rtlil'):
    for ln in open(f'{E}/byteverify_{c}.txt'):
        m = re.match(r'MOVER \./(\w+)/(.+)-([0-9a-f]{8})/slang.uhdm', ln)
        if not m: continue
        mode, name = m.group(1), m.group(2)
        d = f'{P}/{c}/{mode}/{name}-{m.group(3)}'
        cmd = [l for l in open(d + '/cmds.txt') if l.startswith('slang:')][0].split(None, 1)[1]
        argv = shlex.split(cmd)[1:]
        i = argv.index('-o'); argv = argv[:i] + argv[i + 2:]
        pm = md5(d + '/slang.uhdm')
        hits = []
        for sw in SW:
            o = f'/tmp/r11u144_scr/attr_{os.getpid()}.uhdm'
            if os.path.exists(o): os.remove(o)
            env = dict(os.environ); env[sw] = '1'
            subprocess.run([BIN] + argv + ['-o', o], cwd=dirs[c][name], env=env, capture_output=True, timeout=900)
            if md5(o) == pm: hits.append(sw)
            if os.path.exists(o): os.remove(o)
        out.write(f'{c}/{mode}/{name}\tpristine-bytes-under: {" ".join(hits) if hits else "NONE"}\n'); out.flush()
out.close()
print(open(E + '/attribution.txt').read())
