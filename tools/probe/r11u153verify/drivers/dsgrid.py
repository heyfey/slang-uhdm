#!/usr/bin/env python3
# dsgrid.py <out.tsv> <casedir>... : the downstream verdict (scripts/downstream_uhdm2rtlil.py one(): uhdm2rtlil's
# Surelog lane with the downstream flags against the slang lane, Yosys + the plugin on both) of every case for
# three slang-uhdm runs: OFF (the landed binary with the case's law switches, drivers/laws.txt), ON (the landed
# binary) and FIX (the refined binary). Surelog-lane databases cached in a fresh GOLDEN_CACHE (the cases are
# never edited after their first run). Cases only; never a corpus source.
import sys, os, re, subprocess
from concurrent.futures import ThreadPoolExecutor
D = os.path.dirname(os.path.abspath(__file__))
LAWS = {}
for l in open(D + '/laws.txt'):
    p = l.split()
    if p: LAWS[p[0]] = p[1:]
def run(c, tag, binary, env):
    rel = re.sub(r'.*/r11u153verify/cases/', '', c); name = rel.replace('/', '__')
    wr = f'/tmp/r11u153_ds/{tag}'; os.makedirs(wr, exist_ok=True)
    e = dict(os.environ, SLANG_UHDM=binary, GOLDEN_CACHE='/tmp/r11u153_dsgc'); e.update(env)
    code = ("import sys; sys.path.insert(0,'/tmp/wt_r11u153/scripts'); import downstream_uhdm2rtlil as ds; "
            f"r=ds.one({name!r}, {c!r}, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], {wr!r}, 300); "
            "print(r['verdict']+'|'+r['differs'].replace(' ','+'))")
    r = subprocess.run([sys.executable, '-c', code], env=e, capture_output=True, text=True, cwd='/tmp/wt_r11u153')
    return (r.stdout.strip().splitlines() or ['ERR:' + r.stderr.strip()[-80:]])[-1]
def one(c):
    c = os.path.abspath(c); first = open(c + '/dut.sv').readline()
    env = {}
    for l in re.findall(r'(?:§|law) (\w+)', first):
        s = LAWS.get(l, [])
        if s: env[s[0]] = '1'
    off = run(c, 'off', '/tmp/r11u153_bin/pris.bin', env)
    on = run(c, 'on', '/tmp/r11u153_bin/pris.bin', {})
    fx = run(c, 'fix', '/tmp/r11u153_bin/fix.bin', {})
    rel = re.sub(r'.*/r11u153verify/cases/', '', c)
    return f'{rel}\t{off}\t{on}\t{fx}'
with ThreadPoolExecutor(3) as ex:
    rows = list(ex.map(one, sys.argv[2:]))
with open(sys.argv[1], 'w') as f:
    f.write('case\toff\ton\tfix\n')
    for r in sorted(rows): f.write(r + '\n')
