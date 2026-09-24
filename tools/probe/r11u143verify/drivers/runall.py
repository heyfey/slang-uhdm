#!/usr/bin/env python3
"""runall.py <out.jsonl> [--elab] [case dirs...]: every fresh case under cfgs ON / OFF (its own law switch) / A3 (the three
landings off) / extra switches (lawmap.EXTRA); 3 workers; one JSON line per case (case.py's output + group)."""
import sys, os, json, subprocess, glob
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lawmap import M, A3, EXTRA
here=os.path.dirname(os.path.abspath(__file__))
out=sys.argv[1]; args=sys.argv[2:]; elab=False
if args and args[0]=='--elab': elab=True; args=args[1:]
cases=args or sorted(glob.glob(os.path.join(here,'..','cases','*','*')))
def one(c):
    g=os.path.basename(os.path.dirname(c)); law,sw=M[g]
    cf=['ON=','OFF='+sw,'A3='+A3]+['X_'+x+'='+x for x in EXTRA.get(g,[])]
    r=subprocess.run(['python3',os.path.join(here,'case.py')]+(['--elab'] if elab else [])+[c]+cf,capture_output=True,text=True)
    try: j=json.loads(r.stdout.strip().splitlines()[-1])
    except Exception: j={'case':c,'err':r.stderr[-500:]}
    j['group']=g; j['law']=law; j['switch']=sw
    return j
with ThreadPoolExecutor(3) as ex, open(out,'w') as f:
    for j in ex.map(one,[os.path.realpath(c) for c in cases]): f.write(json.dumps(j)+'\n'); f.flush()
