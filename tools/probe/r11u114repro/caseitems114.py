#!/usr/bin/env python3
# (r11u114) caseitems114.py <dump>: every case_item expression object.
# caseitems.py <dump>: per case_item expr object: section, span, kind, name, value
import sys,re
lines=open(sys.argv[1],errors='replace').read().split('\n')
sec='HDR'
out=[]
i=0
n=len(lines)
while i<n:
    l=lines[i]
    if l.startswith('|uhdmallModules'): sec='DEF'
    elif l.startswith('|uhdmtopModules'): sec='TOP'
    elif l.startswith('|uhdmallPackages'): sec='PKGDEF'
    elif l.startswith('|uhdmtopPackages'): sec='PKGTOP'
    elif l.startswith('|uhdmallClasses'): sec='CLS'
    m=re.match(r'^(\s*)\|vpiExpr:$',l)
    if m and i>0:
        # find owner: nearest previous line with smaller indent starting with \_
        ind=len(m.group(1)); j=i-1
        while j>=0:
            mm=re.match(r'^(\s*)\\_(\w+):',lines[j])
            if mm and len(mm.group(1))<ind: break
            j-=1
        if j>=0 and '\\_case_item:' in lines[j]:
            obj=lines[i+1].strip()
            k=i+2; vals=[]
            while k<n and re.match(r'^\s{%d,}'%(ind+2),lines[k]) and not re.match(r'^\s{%d}\S'%(ind),lines[k]):
                s=lines[k].strip()
                if re.match(r'^\|(UINT|INT|BIN|HEX|DEC|vpiSize|vpiName|vpiDecompile|vpiConstType|vpiActual|vpiOpType)',s) and len(lines[k])-len(lines[k].lstrip())==ind+2: vals.append(s)
                if s=='|vpiActual:' : vals.append('ACT:'+lines[k+1].strip()[:60])
                k+=1
            out.append((sec,obj,' '.join(vals)))
    i+=1
for o in out: print(' | '.join(o))
