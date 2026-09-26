#!/usr/bin/env python3
"""fixprior.py <fixbytes output>: every earlier pass's case the refinement moves (fixbytes.sh MOVED, --elabuhdm) is
judged against its own --elabuhdm golden (pinned Surelog, check_probe's arguments + -elabuhdm, cached under
/tmp/r11u173_gres_el): law.bin and fix.bin strict records (uhdm-strictcmp --max 100000), classified like grid.py
(TOWARD / AWAY / MIXED / UNMASK / STAGE1-x by order-blind dump distance).  Cases are read in place, never copied.
Fail-closed on $FENCED."""
import os, re, sys, subprocess, collections, hashlib
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('fixprior.py: source drivers/env.sh first')
D = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, D)
src = open(f'{D}/grid.py').read(); src = src[:src.index('def main():')]
ns = {'__file__': f'{D}/grid.py'}; exec(src, ns)
SL, SC, LAW, FIX = os.environ['SURELOG'], os.environ['STRICT_CMP'], os.environ['LAW'], os.environ['FIX']
R = '/tmp/wt_r11u173/tools/probe/'
for l in open(sys.argv[1]):
    f = l.split('\t')
    if len(f) < 3 or f[2].strip() != 'MOVED' or f[1] != 'el': continue
    rel = f[0]; c = R + rel
    if any(re.search(rf'\b{re.escape(n)}\b', c) for n in F): print('FENCED-SKIP', rel); continue
    w = f'/tmp/r11u173_gres_el/{rel}'; os.makedirs(w, exist_ok=True)
    h = hashlib.md5(open(f'{c}/dut.sv', 'rb').read()).hexdigest()[:12]
    g = f'{w}/gold_{h}/golden.uhdm'
    if not os.path.exists(g):
        os.makedirs(f'{w}/gold_{h}/w', exist_ok=True)
        subprocess.run(f'cd {c} && timeout 300 {SL} -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -elabuhdm -o {w}/gold_{h}/w > {w}/gold_{h}/sl.log 2>&1', shell=True)
        u = subprocess.run(f'find {w}/gold_{h}/w -name "*.uhdm" | head -1', shell=True, capture_output=True, text=True).stdout.strip()
        if u: os.replace(u, g)
    if not os.path.exists(g): print('RESULT', rel, 'NOGOLD'); continue
    for t, b in (('on', LAW), ('fix', FIX)):
        o = f'{w}/{t}.uhdm'
        if os.path.exists(o): os.remove(o)
        subprocess.run(f'cd {c} && timeout 300 {b} dut.sv --single-unit --nobuiltin --elabuhdm -o {o} > {w}/{t}.log 2>&1', shell=True)
        if os.path.exists(o):
            subprocess.run(f'{SC} --max 100000 {g} {o} > {w}/{t}.strict 2>&1', shell=True)
    v, det = ns['score'](w, 'fix', 'on', g)
    last = lambda t: (open(f'{w}/{t}.strict').read().splitlines() or ['-'])[-1] if os.path.exists(f'{w}/{t}.strict') else 'NODB'
    print('RESULT', rel, v, '| law:', last('on'), '| fix:', last('fix'), '|', det, flush=True)
