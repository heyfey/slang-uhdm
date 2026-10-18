import sys,re
# usage: meth.py dump classfullname  -> prints methods names in order of the first expanded listing
f=open(sys.argv[1]); cls=sys.argv[2]; lines=f.readlines()
for i,l in enumerate(lines):
    m=re.match(r'^( *)\\_class_defn: \('+re.escape(cls)+r'\)',l)
    if m and i+1<len(lines) and lines[i+1].strip()=='|vpiParent:':
        ind=len(m.group(1)); out=[]
        for l2 in lines[i+1:]:
            sp=len(l2)-len(l2.lstrip(' '))
            if sp<=ind and l2.lstrip().startswith('\\_'): break
            mm=re.match(r'^ {%d}\\_(function|task): \(([^)]*)\)(.*)'%(ind+2),l2)
            if mm: out.append(mm.group(2)+mm.group(3))
        print('\n'.join(out)); break
