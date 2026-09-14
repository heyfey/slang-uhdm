import sys,re,collections
def parse(path):
    lines=open(path,encoding='utf-8',errors='replace').read().split('\n')
    sec='?';cur=None;blocks=[];byind={}
    for i,l in enumerate(lines):
        if l.startswith('|uhdm') and l.endswith(':'): sec=l.strip('|:')
        m=re.match(r'^(\s*)\\_struct_typespec: \((.*?)\)',l)
        if m:
            b={'sec':sec,'line':i+1,'name':m.group(2),'ind':len(m.group(1)),'mem':[]}
            byind[len(m.group(1))]=b; blocks.append(b); cur=None; continue
        m=re.match(r'^(\s*)\\_typespec_member: \((.*?)\)',l)
        if m:
            ind=len(m.group(1))
            if cur is not None and ind>cur[1]: continue
            b=byind.get(ind-2)
            cur=[m.group(2),ind,0,b]
            if b is not None: b['mem'].append(cur)
            continue
        if cur is not None and re.match(r'^\s*\|vpiExpr:',l) and (len(l)-len(l.lstrip()))==cur[1]+2:
            cur[2]+=1
    return blocks
for p in sys.argv[1:]:
    print('##',p)
    for b in parse(p):
        if not b['mem']: continue
        st=sum(1 for m in b['mem'] if m[2])
        print(f"   {b['sec']:18s} L{b['line']:6d} {b['name']:34s} members={len(b['mem']):3d} stamped={st:3d}")
# stamps.py <dump...> — per-struct-typespec-copy census of the EvalFunc member
# leftovers (`typespec_member |vpiExpr:`), by dump SECTION.  Golden's split is
# the law: the DEF PACKAGE listing is CLEAN, every view that resolved the
# typedef after elaboration is STAMPED.  uhdm-dump prints a nested back-
# reference of each member inside its own ref_typespec, so only the OUTERMOST
# typespec_member at a given indent is counted.
