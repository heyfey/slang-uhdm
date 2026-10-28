import os,re,sys
fen=[l.strip() for l in open('/tmp/r11u453_scr/fenced.txt') if l.strip()]
roots=sys.argv[1:]
pA=re.compile(r'\bimport\s+\w+::\w+\s*[;,]')
pB=re.compile(r'(\[\s*\(|(?<![:])(?:\+:|-:|:)\s*\()[^\]\n]*\]|\[[^\[\]\n]*\)\s*(?:\+:|-:|:)')
pD=re.compile(r'\b\w+\s*\[[^\[\]\n]+\]\s*\[[^\[\]\n]*(?:\+:|-:|[^:]:[^:])[^\[\]\n]*\]')
out={'A':[],'B':[],'D':[]}
n=0
for r in roots:
  for dp,dn,fn in os.walk(r):
    if any(f in dp for f in fen): continue
    for f in fn:
      if not f.endswith(('.sv','.v','.svh','.vh','.pkg')): continue
      p=os.path.join(dp,f)
      if any(x in p for x in fen): continue
      n+=1
      try: t=open(p,errors='replace').read()
      except: continue
      t2=re.sub(r'//[^\n]*','',t)
      if pA.search(t2): out['A'].append(p)
      if pB.search(t2): out['B'].append(p)
      if ('package' in t2 or 'class' in t2) and pD.search(t2): out['D'].append(p)
print('files',n)
for k,v in out.items():
  open('/tmp/r11u453_scr/scan_%s.txt'%k,'w').write('\n'.join(v)+'\n'); print(k,len(v))
