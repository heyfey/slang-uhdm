import sys,re
lines=open(sys.argv[1],errors='replace').read().split('\n')
cur=None;field=None;out={};sect=''
for l in lines:
    m=re.match(r'^\|(uhdm\w+):$',l)
    if m: sect=m.group(1); cur=None; continue
    m=re.match(r'^\\_package: (\S+) ',l)
    if m and sect in('uhdmallPackages','uhdmtopPackages'):
        cur=(sect[4:7],m.group(1)); out.setdefault(cur,{}); field=None; continue
    m=re.match(r'^\\_module_inst: (\S+) ',l)
    if m and sect in('uhdmallModules','uhdmtopModules'):
        cur=(sect[4:7],m.group(1)); out.setdefault(cur,{}); field=None; continue
    if cur is None: continue
    m=re.match(r'^  \|(vpi\w+):',l)
    if m: field=m.group(1); continue
    m=re.match(r'^  \\_(\w+): (.*)',l)
    if m and field:
        nm=m.group(2); mm=re.search(r'\(([^)]*)\)',nm); nm=mm.group(1) if mm else nm.split(',')[0]
        out[cur].setdefault(field,[]).append(nm.split('::')[-1].split('.')[-1]); continue
want=sys.argv[2:]
for k,v in out.items():
    if want and k[1] not in want: continue
    for f in ('vpiVariables','vpiNet','vpiParamAssign','vpiParameter'):
        if f in v: print(k[0],k[1],f,len(v[f]),' '.join(v[f][:60]))
