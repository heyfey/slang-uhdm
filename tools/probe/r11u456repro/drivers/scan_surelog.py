import os, re, sys
SR='/home/heyfey/git-repos/slang-uhdm/third_party/Surelog'
F=[l.strip() for l in open('/tmp/r11u456_fenced.txt') if l.strip()]
def fenced(s): return any(f in s for f in F)
A=re.compile(r'\binterface\b'); A2=re.compile(r'\b(wait|fork|assert|foreach)\b|\$\w+\s*\(|\w\s*\(\s*\w')
B=re.compile(r'\b(function|task)\b[^;]*\w::\w'); B2=re.compile(r'\bthis\b'); UVM=re.compile(r'uvm_pkg|uvm_macros')
out={'A':[], 'B':[]}
for root in (SR+'/tests', SR+'/third_party/tests'):
  for dp, ds, fs in os.walk(root):
    if fenced(dp): ds[:]=[]; continue
    for fn in fs:
      if not fn.endswith('.sl'): continue
      name=fn[:-3]
      if fenced(name): continue
      txt=''
      for d2, _, f2 in os.walk(dp):
        if fenced(d2): continue
        for g in f2:
          if fenced(g): continue
          if g.endswith(('.sv','.v','.svh','.vh','.sl','.f')):
            try: txt+=open(os.path.join(d2,g),errors='ignore').read()
            except: pass
      if A.search(txt) and A2.search(txt): out['A'].append(name)
      if (B.search(txt) and B2.search(txt)) or UVM.search(txt): out['B'].append(name)
for k in out:
  open('/tmp/r11u456_scan/cand_sl_'+k+'.txt','w').write('\n'.join(sorted(set(out[k])))+'\n')
  print(k, len(set(out[k])))
