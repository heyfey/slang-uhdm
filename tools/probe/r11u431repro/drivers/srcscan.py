import os,re,sys
fence=[l.strip() for l in open('/tmp/r11u431_scr/fenced.txt') if l.strip()]
SR='/home/heyfey/git-repos/slang-uhdm/third_party/Surelog'
roots={'surelog':[SR+'/tests', SR+'/third_party/tests'],
       'u2r':['/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test'],
       'probe':['/home/heyfey/git-repos/slang-uhdm/tests/probe']}
p_tp=re.compile(r'\bparameter\s+type\b')
p_arr=re.compile(r'\b(parameter|localparam)\b[^;=]*\[[^\]]*[A-Za-z_][^\]]*\][^;=,)]*\b\w+\s*\[')
out={'tp':set(),'arr':set()}; n=0
for tag,rs in roots.items():
    for r in rs:
        for dp,ds,fs in os.walk(r):
            if any(f in dp for f in fence): continue
            for f in fs:
                if not f.endswith(('.sv','.v','.svh','.vh')) or any(x in f for x in fence): continue
                p=os.path.join(dp,f); n+=1
                try: s=open(p,errors='replace').read()
                except Exception: continue
                if p_tp.search(s): out['tp'].add((tag,dp))
                if p_arr.search(s): out['arr'].add((tag,dp))
print('files',n,file=sys.stderr)
for k,v in out.items():
    for t,d in sorted(v): print(k,t,d)
