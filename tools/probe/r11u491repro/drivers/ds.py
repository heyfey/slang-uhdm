#!/usr/bin/env python3
# ds.py <binary> <tag> <casedir>...: downstream verdict of each case dir (uhdm2rtlil harness one())
import os, sys, concurrent.futures
os.environ['SLANG_UHDM'] = sys.argv[1]
sys.path.insert(0, '/tmp/wt_r11u491/scripts')
import downstream_uhdm2rtlil as ds
tag = sys.argv[2]
def run(c):
    name = c.split('/cases/')[-1].replace('/', '_')
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/r11u491_ds_' + tag, 300)
    return f"{c.split('/cases/')[-1]} {r['verdict']} {r['differs']}"
with concurrent.futures.ThreadPoolExecutor(3) as ex:
    for l in ex.map(run, sys.argv[3:]): print(l, flush=True)
