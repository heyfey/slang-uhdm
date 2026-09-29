#!/usr/bin/env python3
# (r11u229: copied from r11u226verify/drivers/casefirst.py; the known laws also read uhdm_main.cpp, where pass 223 put three.)
# (r11u213) casefirst.py <dir under tools/probe>...: every case directory (a dut.sv, a dut.v or an `args` file) of
# the given evidence directories: does its first file's first line (or a LAW file) name a `§ law`, and does every law
# named exist in src/ or include/ (grep of `§ <name>`)?  Reads only case texts of these directories.
import os, re, sys, subprocess
R = os.path.realpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../..'))
src = subprocess.run(['grep', '-rhoE', '§ [A-Za-z0-9_]+', f'{R}/src', f'{R}/include', f'{R}/uhdm_main.cpp'], capture_output=True, text=True).stdout
known = set(l.split()[1] for l in src.splitlines())
for d in sys.argv[1:]:
    n = ok = nolaw = 0; missing = set()
    for root, dirs, files in os.walk(f'{R}/tools/probe/{d}/cases'):
        f = next((x for x in ('dut.sv', 'dut.v') if x in files), None)
        if 'args' in files: f = open(f'{root}/args').read().split()[0]
        if not f: continue
        n += 1
        laws = re.findall(r'§ ?([A-Za-z0-9_]+)', open(f'{root}/{f}', errors='replace').readline())
        if os.path.exists(f'{root}/LAW'): laws += open(f'{root}/LAW').read().split()
        if not laws: nolaw += 1; print('  NO-LAW', os.path.relpath(root, R)); continue
        ok += 1; missing |= {l for l in laws if l not in known}
    print(f'{d}: cases={n} with_law={ok} without={nolaw} laws_not_in_src={sorted(missing) or "-"}')
