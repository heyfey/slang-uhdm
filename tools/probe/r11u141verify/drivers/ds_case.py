#!/usr/bin/env python3
"""ds_case.py <tag> <ENV1,ENV2|-> <casedir> : downstream verdict of one case (harness one(), HEAD scripts) under env."""
import sys, os, json, re
tag, envs, c = sys.argv[1:4]
for e in filter(None, envs.split(',')):
    if e != '-': os.environ[e] = '1'
os.environ.setdefault('GOLDEN_CACHE', '/tmp/r11u141_dsgc')
sys.path.insert(0, '/tmp/wt_r11u141/scripts')
import downstream_uhdm2rtlil as ds
name = re.sub(r'[^A-Za-z0-9_]', '_', '/'.join(c.rstrip('/').split('/')[-2:]))
r = ds.one(name, c.rstrip('/'), ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], f'/tmp/r11u141_ds/{tag}', 300)
r['tag'] = tag; r['case'] = c
print(json.dumps(r))
