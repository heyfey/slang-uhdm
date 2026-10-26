import os,re,csv
fence=[l.strip() for l in open('/tmp/r11u431_scr/fenced.txt') if l.strip()]
ST='/home/heyfey/git-repos/sv-tests'
rows=[r[0] for r in csv.reader(open('/home/heyfey/git-repos/slang-uhdm/results/golden_svtests.csv')) if r and r[0]!='case']
kw_open=re.compile(r'^\s*(?:(?:virtual|static|automatic|extern|pure)\s+)*(module|macromodule|interface|program|package|class|function|task|checker|primitive|config)\b')
kw_close=re.compile(r'^\s*(endmodule|endinterface|endprogram|endpackage|endclass|endfunction|endtask|endchecker|endprimitive|endconfig)\b')
pparam=re.compile(r'^\s*(localparam|parameter)\b')
def unit_param(txt):
    depth=0
    for line in txt.split('\n'):
        if kw_close.search(line): depth=max(0,depth-1); continue
        if kw_open.search(line) and not re.search(r'\bextern\b',line): depth+=1; continue
        if depth==0 and pparam.search(line): return True
    return False
p_tp=re.compile(r'\bparameter\s+type\b')
p_conn=re.compile(r'\.\w+\s*\([^;()]*[\[\^&|+\-*~?{][^;()]*\)')
p_par=re.compile(r'\b(localparam|parameter)\b')
p_cat=re.compile(r'assign[^;]*\w\s*\(\s*\{')
p_arr=re.compile(r'\b(parameter|localparam)\b[^;=]*\[[^\]]*[A-Za-z_][^\]]*\][^;=,)]*\b\w+\s*\[')
c={k:[] for k in ['unit','tp','conn','cat','arr','any']}
for rel in rows:
    if any(f in rel for f in fence): continue
    p=os.path.join(ST,'tests',rel)
    try: s=open(p,errors='replace').read()
    except Exception: continue
    files=[p]
    m=re.search(r':files:(.*)',s)
    if m: files+= [f for f in m.group(1).split() if not any(x in f for x in fence)]
    m=re.search(r':incdirs:(.*)',s)
    inc=m.group(1).split() if m else []
    txt=''
    for f in files:
        try: txt+=open(f,errors='replace').read()+'\n'
        except Exception: pass
    for d in inc:
        if any(x in d for x in fence): continue
        try:
            for fn in os.listdir(d):
                if fn.endswith(('.sv','.svh','.v','.vh')) and not any(x in fn for x in fence):
                    try: txt+=open(os.path.join(d,fn),errors='replace').read()+'\n'
                    except Exception: pass
        except Exception: pass
    hit=False
    if unit_param(txt): c['unit'].append(rel); hit=True
    if p_tp.search(txt): c['tp'].append(rel); hit=True
    if p_conn.search(txt) and p_par.search(txt): c['conn'].append(rel); hit=True
    if p_cat.search(txt): c['cat'].append(rel); hit=True
    if p_arr.search(txt): c['arr'].append(rel); hit=True
    if hit: c['any'].append(rel)
for k,v in c.items():
    open('/tmp/r11u431_scan/sv_%s.lst'%k,'w').write('\n'.join(v)+'\n')
    print(k,len(v))
