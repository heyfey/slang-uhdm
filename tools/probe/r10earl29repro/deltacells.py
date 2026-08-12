import sys,re
def load(p):
    d={}; key=None
    for ln in open(p):
        m=re.match(r'^(\S+)\s+(\S+)\s+(EQ|DIFFER|MISSING)$', ln.rstrip())
        if m: key=(m.group(1),m.group(2)); d[key]=[m.group(3),'','','']; continue
        if key:
            if ln.startswith('    SRC'):    d[key][1]=ln.strip()[4:].strip()
            elif ln.startswith('    GOLDEN'):d[key][2]=ln.strip()[7:].strip()
            elif ln.startswith('    OURS'):  d[key][3]=ln.strip()[5:].strip()
    return d
arm=sys.argv[1]
b=load(sys.argv[2]); p=load(sys.argv[3])
only=sys.argv[4] if len(sys.argv)>4 else None
for k in sorted(set(b)|set(p), key=lambda k:(k[1],k[0])):
    if only and k[0]!=only: continue
    bb=b.get(k,['-ABSENT-','','','']); pp=p.get(k,['-ABSENT-','','',''])
    changed = bb[3]!=pp[3]
    if pp[0]=='EQ' and not changed: continue      # already right, untouched
    tag=[]
    if bb[0]=='EQ' and pp[0]!='EQ': tag.append('OVER-FIRE')
    if bb[0]!='EQ' and pp[0]=='EQ': tag.append('FIXED')
    if bb[0]!='EQ' and pp[0]!='EQ': tag.append('CHANGED-STILL-WRONG' if changed else 'UNCHANGED-STILL-WRONG')
    print(f"{arm} {k[0]:<11} {k[1]:<16} {'+'.join(tag)}")
    print(f"    SRC        {pp[1] or bb[1]}")
    print(f"    GOLDEN     {pp[2] or bb[2]}")
    print(f"    BASE-OURS  {bb[3]}")
    print(f"    PATCH-OURS {pp[3]}")
