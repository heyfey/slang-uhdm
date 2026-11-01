# scan_cand.py: corpus rows (Surelog tests, uhdm2rtlil tests) whose sources hold
# a package with an aggregate or vector typedef AND either two importers or a
# package subroutine (the shapes the pass-458 drains can touch); fence-filtered
# before any file is opened.
import os, re, sys
SR='/home/heyfey/git-repos/slang-uhdm/third_party/Surelog'
U2R='/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test'
F=[l.strip() for l in open('/tmp/r11u458_fenced.txt') if l.strip()]
def fenced(s): return any(f in s for f in F)
PK=re.compile(r'\bpackage\b'); TD=re.compile(r'\btypedef\s+(struct|union|enum|bit|logic)\b')
TF=re.compile(r'\b(task|function)\b'); IMP=re.compile(r'\bimport\s+\w+::'); UVM=re.compile(r'uvm_pkg|uvm_macros|svunit_pkg|\.f\b|-f ')
def scan(roots, ext_sl):
  out=[]
  for root in roots:
    for dp, ds, fs in os.walk(root):
      if fenced(dp): ds[:]=[]; continue
      for fn in fs:
        if not fn.endswith(ext_sl): continue
        name=fn[:-len(ext_sl)] if ext_sl=='.sl' else os.path.basename(dp)
        if fenced(name): continue
        txt=''
        for d2, _, f2 in os.walk(dp):
          if fenced(d2): continue
          for g in f2:
            if fenced(g): continue
            if g.endswith(('.sv','.v','.svh','.vh','.pkg','.sl','.f')):
              try: txt+=open(os.path.join(d2,g),errors='ignore').read()
              except: pass
        if UVM.search(txt) or (PK.search(txt) and TD.search(txt) and (len(IMP.findall(txt))>=2 or TF.search(txt))):
          out.append(name)
  return sorted(set(out))
sl=scan([SR+'/tests', SR+'/third_party/tests'], '.sl')
open('/tmp/r11u458_scan/cand_sl.txt','w').write('\n'.join(sl)+'\n')
print('surelog candidates', len(sl))
