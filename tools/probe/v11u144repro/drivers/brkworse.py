import re, subprocess, sys, glob
SC='/tmp/v11u144_bin/uhdm-strictcmp'
def recs(g,o):
    out=subprocess.run([SC,'--max','1000000',g,o],capture_output=True,text=True).stdout
    d={int(m.group(1)):m.group(2) for m in re.finditer(r'^#(\d+) (\w+)',out,re.M)}
    return d,'(walk diverged)' in out
for c in sys.argv[1:]:
    w=[x.rsplit('/',1)[0] for x in glob.glob('/tmp/v11u144_cw/*/dir') if open(x).read().strip()=='/tmp/v11u144_cases/'+c][0]
    dp,vp=recs(w+'/golden.uhdm',w+'/P.uhdm'); dl,vl=recs(w+'/golden.uhdm',w+'/L.uhdm')
    pdiv=min([i for i,f in dp.items() if f in('type','depth','count','name')],default=10**12) if vp else 10**12
    new=[i for i in dl if i<pdiv and i not in dp]
    print(('NEW' if new else 'IMPROVE' if set(dl)<=set(dp) else 'UNMASK'), c, f'P={len(dp)} div={vp}', f'L={len(dl)} div={vl}', new[:5])
