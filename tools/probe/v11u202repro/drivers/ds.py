#!/usr/bin/env python3
# v11u202: downstream one() on case dirs with each binary in $BINS (fail closed on the fence)
import os, re, sys, subprocess
repo=os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','..','..','..'))
fl=[l for l in open(repo+'/tools/probe/r11u107repro/canaudit.sh') if l.startswith('FENCED=')]
fenced=fl[0].split('=',1)[1].strip().strip('"\'').split(); assert len(fenced)==4
sys.path.insert(0, repo+'/scripts')
bins=os.environ.get('BINS','pris law').split()
out=[]
for d in sys.argv[1:]:
    d=os.path.abspath(d)
    if any(re.search(r'\b%s\b'%re.escape(f), d) for f in fenced): sys.exit('fenced')
    res=[]
    for b in bins:
        os.environ['SLANG_UHDM']=os.environ.get('VB','/tmp/v11u202_bin')+f'/{b}.bin'
        import importlib
        import downstream_uhdm2rtlil as ds; importlib.reload(ds)
        name=os.path.basename(os.path.dirname(d))+'_'+os.path.basename(d)
        r=ds.one(name, d, ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], f'/tmp/v11u202_dsw/{b}', 300)
        res.append(f"{b}={r['verdict']}({r.get('slang_gates','')}/{r.get('surelog_gates','')}{',differs='+r['differs'] if r['differs'] else ''})")
    print(os.path.relpath(d,'/tmp/v11u202_cases'), ' '.join(res), flush=True)
