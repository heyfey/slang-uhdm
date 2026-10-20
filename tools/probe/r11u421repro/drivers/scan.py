#!/usr/bin/env python3
# r11u421 source scan: list candidate corpus/probe/sv-tests sources for each law's shape.
# Builds the path list first and filters it on the fence list before opening any file.
import os, re, sys
fenced=[l.strip() for l in open('/tmp/r11u421_fenced.txt') if l.strip()]
roots={'surelog':['/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/tests','/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/tests'],
 'u2r':['/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test'],
 'probe':['/tmp/wt_r11u421/tests/probe'],
 'svtests':['/home/heyfey/git-repos/sv-tests/tests','/home/heyfey/git-repos/sv-tests/third_party']}
pats={
 'expect': re.compile(r'\bexpect\s*\('),
 'ipssys': re.compile(r'\.\s*\w+\s*\[[^\]\n]*\$\w+\s*\([^\]\n]*[+-]:|\.\s*\w+\s*\[[^\]\n]*[+-]:[^\]\n]*\$\w+\s*\('),
 'pisysbs': re.compile(r'\b(parameter|localparam)\b[^;]*\$\w+\s*\(\s*[\w.]+\s*\['),
 'bitsdef': re.compile(r'\b(parameter|localparam)\b[^;]*=\s*\$bits\s*\('),
}
out=open(sys.argv[1],'w'); n=0; skipped=0
for corp,rs in roots.items():
  for r in rs:
    for dp,dn,fn in os.walk(r):
      dn[:]=[d for d in dn if d!='.git']
      for f in fn:
        if not re.search(r'\.(sv|v|svh|vh|pkg)$',f): continue
        p=os.path.join(dp,f)
        if any(x in p for x in fenced): skipped+=1; continue
        try: t=open(p,errors='replace').read()
        except Exception: continue
        n+=1
        for k,rx in pats.items():
          for m in rx.finditer(t):
            ln=t.count('\n',0,m.start())+1
            out.write(f'{k}\t{corp}\t{p}:{ln}\n')
print('files',n,'fence-skipped',skipped)
