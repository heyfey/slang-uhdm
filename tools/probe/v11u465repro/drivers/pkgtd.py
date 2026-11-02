import sys,re,subprocess
# pkgtd.py <uhdm>: per top-level package block (in dump order), its direct vpiTypedef entries
out=subprocess.run([sys.argv[2] if len(sys.argv)>2 else '/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump',sys.argv[1]],capture_output=True,text=True).stdout.splitlines()
cur=None;res=[]
for i,l in enumerate(out):
    m=re.match(r'^(\s*)\\_package: (\S+)',l)
    if m and len(m.group(1))==0:
        cur=[m.group(2),[]];res.append(cur);continue
    m2=re.match(r'^(\s*)\\_(?:\w+)',l)
    if m2 and len(m2.group(1))==0: cur=None
    if cur and re.match(r'^  \|vpiTypedef:',l):
        nx=out[i+1].strip()
        mm=re.match(r'\\_(\w+): \(([^)]*)\)(.*)',nx)
        cur[1].append(f"{mm.group(1)}:{mm.group(2)}" if mm else nx)
for p,t in res: print(p, len(t), ' '.join(t))
