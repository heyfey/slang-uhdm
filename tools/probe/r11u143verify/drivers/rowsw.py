#!/usr/bin/env python3
"""rowsw.py <corpus> <mode> <test> <cfg>...  cfg = NAME=ENV1,ENV2 ('ON=' for none): runs the frozen base binary on one
corpus row-mode (the harness's own command line, from verify_golden.py) under each switch set; prints md5, strict verdict
and fields per cfg; the golden is the cached one the base sweep used. Databases under /tmp/r11u143_rowsw/<test>_<mode>/."""
import sys, os, subprocess, hashlib, glob, re
sys.path.insert(0,'/tmp/wt_r11u143/scripts')
import verify_golden as vg
corp,mode,test=sys.argv[1:4]; cfgs=sys.argv[4:]
tests=vg.discover_surelog('^'+re.escape(test)+'$') if corp=='surelog' else vg.discover_uhdm2rtlil('^'+re.escape(test)+'$')
dirpath,parts=tests[test]
if mode=='default':
    sources,_=vg.split_sources(parts); loc,_=vg.location_args(parts)
    su=[vg.LOCATION_RENAME.get(a,a) for a in loc]+list(sources)+['--single-unit']
else:
    su,blocking,nodb,nob=vg.translate(parts)
    if nob: su=su+['--nobuiltin']
d=glob.glob(f'/tmp/r11u143_wdON/{corp}/{mode}/{test}-*/cmds.txt')[0]
g=re.search(r'golden cache hit ([^)]*)\)',open(d).read()).group(1)+'/golden.uhdm'
W=f'/tmp/r11u143_rowsw/{test}_{mode}'; os.makedirs(W,exist_ok=True)
for c in cfgs:
    name,_,envs=c.partition('='); e=dict(os.environ)
    for x in filter(None,envs.split(',')): e[x]='1'
    o=f'{W}/{name}.uhdm'
    if os.path.exists(o): os.unlink(o)
    subprocess.run(['/tmp/r11u143_bin/slang']+su+['-o',o],cwd=dirpath,env=e,capture_output=True,timeout=3000)
    md=hashlib.md5(open(o,'rb').read()).hexdigest()[:12] if os.path.exists(o) else None
    s=subprocess.run(['/tmp/r11u143_bin/strictcmp','--max','0',g,o],capture_output=True,text=True,timeout=3000) if md else None
    ls=(s.stdout+s.stderr).strip().splitlines() if s else []
    f=next((l for l in ls if l.startswith('fields:')),'')
    print(f'{corp}\t{mode}\t{test}\t{name}\t{md}\t{ls[-1] if ls else "nodb"}\t{f}',flush=True)
