#!/usr/bin/env python3
"""runfix.py <out.jsonl> [--elab] dirs... : fix binary under F (all on), FOFF (R11V141_OFF), FQ (R11V141_IPSQUAL_OFF), FT (R11V141_INCTABACT_OFF)"""
import sys, subprocess, os
from concurrent.futures import ThreadPoolExecutor
out=sys.argv[1]; a=sys.argv[2:]; elab='--elab' in a; cs=[x for x in a if not x.startswith('--')]
env=dict(os.environ); env['R141_BIN']='/tmp/r11u141_bin/fix'
def one(c):
    return subprocess.run(['python3','/tmp/r11u141_drv/case.py']+(['--elab'] if elab else [])+[c,'F=','FOFF=R11V141_OFF','FQ=R11V141_IPSQUAL_OFF','FT=R11V141_INCTABACT_OFF'],capture_output=True,text=True,env=env).stdout.strip()
with ThreadPoolExecutor(3) as ex, open(out,'w') as f:
    for l in ex.map(one,cs): f.write(l+'\n')
