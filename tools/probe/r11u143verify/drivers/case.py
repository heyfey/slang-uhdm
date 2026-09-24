#!/usr/bin/env python3
"""case.py [--elab] <casedir> cfg=ENV[,ENV..] ...  -> one JSON line per case
Golden: pinned Surelog -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 [-elabuhdm], cached by content md5.
Ours: frozen slang dut.sv --single-unit --nobuiltin [--elabuhdm] under each cfg's environment.
Per cfg: rc, uhdm md5, uhdm-cmp line count, strict verdict, strict fields line, record dump path."""
import sys, os, subprocess, hashlib, json, shutil, tempfile
SUR=os.environ.get('SURELOG','/home/heyfey/git-repos/Surelog/build/bin/surelog')
CMP=os.environ.get('UHDM_CMP','/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp')
SL=os.environ.get('R143_BIN','/tmp/r11u143_bin/slang'); SC='/tmp/r11u143_bin/strictcmp'; SX='/tmp/r11u143_bin/strictx'
GC='/tmp/r11u143_gc'; CW='/tmp/r11u143_cases'
args=sys.argv[1:]; elab=False
if args and args[0]=='--elab': elab=True; args=args[1:]
d=os.path.realpath(args[0]); cfgs=args[1:] or ['ON=']
h=hashlib.md5()
for root,_,fs in sorted(os.walk(d)):
    for f in sorted(fs):
        if f in ('LAW',): continue
        p=os.path.join(root,f); h.update(os.path.relpath(p,d).encode()); h.update(open(p,'rb').read())
h.update(b'elab' if elab else b'')
key=h.hexdigest()[:20]
g=f'{GC}/{key}.uhdm'
if not os.path.exists(g) and not os.path.exists(g+'.fail'):
    w=tempfile.mkdtemp(prefix='r11u143_sl',dir='/tmp')
    cmd=[SUR,'-parse','-nobuiltin','-nocache','-sv','dut.sv','-mt','0','-mp','0']+(['-elabuhdm'] if elab else [])+['-o',w]
    subprocess.run(cmd,cwd=d,capture_output=True,timeout=600,stdin=subprocess.DEVNULL)
    f=os.path.join(w,'slpp_all','surelog.uhdm')
    if os.path.exists(f) and os.path.getsize(f)>0: shutil.copy(f,g)
    else: open(g+'.fail','w').close()
    shutil.rmtree(w,ignore_errors=True)
wd=f'{CW}/{key}'; os.makedirs(wd,exist_ok=True)
open(wd+'/dir','w').write(d+('\telab' if elab else '')+'\n')
res={'case':d,'key':key,'elab':elab,'golden':os.path.exists(g)}
if res['golden'] and not os.path.exists(wd+'/g.rec'):
    pass
for c in cfgs:
    name,_,env=c.partition('=')
    e=dict(os.environ)
    for kv in filter(None,env.split(',')): e[kv]='1'
    o=f'{wd}/{name}.uhdm'
    for ext in ('uhdm','rec','diffs'):
        if os.path.exists(f'{wd}/{name}.{ext}'): os.unlink(f'{wd}/{name}.{ext}')
    if os.path.exists(f'{wd}/g_{name}.rec'): os.unlink(f'{wd}/g_{name}.rec')
    r=subprocess.run([SL,'dut.sv','--single-unit','--nobuiltin']+(['--elabuhdm'] if elab else [])+['-o',o],cwd=d,env=e,capture_output=True,text=True,timeout=600,stdin=subprocess.DEVNULL)
    x={'rc':r.returncode}
    if os.path.exists(o) and os.path.getsize(o)>0:
        x['md5']=hashlib.md5(open(o,'rb').read()).hexdigest()[:12]
        if res['golden']:
            cm=subprocess.run([CMP,g,o],capture_output=True,text=True)
            x['cmp']=len((cm.stdout+cm.stderr).splitlines())
            s=subprocess.run([SC,'--max','0',g,o],capture_output=True,text=True)
            subprocess.run([SX,'--max','0','--diffs',f'{wd}/{name}.diffs','--dump-a',f'{wd}/g_{name}.rec','--dump-b',f'{wd}/{name}.rec',g,o],capture_output=True,text=True)
            ls=(s.stdout+s.stderr).strip().splitlines()
            x['strict']=ls[-1] if ls else ''
            x['fields']=next((l for l in ls if l.startswith('fields:')),'')
    else: x['md5']=None
    res[name]=x
print(json.dumps(res))
