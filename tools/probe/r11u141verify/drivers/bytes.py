#!/usr/bin/env python3
"""bytes.py <dirs.txt> <out> : pristine vs fix bytes per case dir (both `dut.sv --single-unit --nobuiltin`), fixed path per case"""
import sys, subprocess, hashlib, os
from concurrent.futures import ThreadPoolExecutor
ds=[l.strip() for l in open(sys.argv[1]) if l.strip()]
def run(b,d,o):
    if os.path.exists(o): os.unlink(o)
    r=subprocess.run([b,'dut.sv','--single-unit','--nobuiltin','-o',o],cwd=d,capture_output=True,timeout=600)
    return r.returncode, (hashlib.md5(open(o,'rb').read()).hexdigest() if os.path.exists(o) else None)
def one(d):
    k=hashlib.md5(d.encode()).hexdigest()[:12]; w=f'/tmp/r11u141_bytes/{k}'; os.makedirs(w,exist_ok=True)
    a=run('/tmp/r11u141_bin/slang',d,w+'/P.uhdm'); b=run('/tmp/r11u141_bin/fix',d,w+'/F.uhdm')
    return f"{'SAME' if a==b else 'MOVED'}\t{d}\tP={a}\tF={b}\t{w}"
with ThreadPoolExecutor(3) as ex, open(sys.argv[2],'w') as f:
    for l in ex.map(one,ds): f.write(l+'\n')
