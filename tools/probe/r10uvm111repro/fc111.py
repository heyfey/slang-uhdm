# fc111.py — census of func_call / method_func_call -> vpiFunction|vpiTask bindings
# from a uhdm-dump text tree, keyed by (call name, callee synthesized fullname,
# callee parent kind).  Also records the nearest enclosing 0-indent container
# and section (allPackages/topPackages/allModules/... ) so a cell names a view.
import sys, re
path=sys.argv[1]
sec=""
cont=""
# stack of (indent, kind, name)
stack=[]
rows=[]
pend=None   # (indent_of_field, field_name, call_name)
callstack=[]  # (indent, callname)
objre=re.compile(r'^(\s*)\\_(\w+): \(([^)]*)\)')
objre2=re.compile(r'^(\s*)\\_(\w+): ([^,]*)')
fldre=re.compile(r'^(\s*)\|(\w+):')
secre=re.compile(r'^\|uhdm(\w+):')
import io
fh = sys.stdin if path=="-" else open(path, errors="replace")
for line in fh:
    line=line.rstrip('\n')
    m=secre.match(line)
    if m:
        sec=m.group(1); continue
    m=objre.match(line)
    if not m:
        m=objre2.match(line)
    if m:
        ind=len(m.group(1)); kind=m.group(2); name=m.group(3).strip()
        if ind==0:
            cont=kind+":"+name
        while callstack and callstack[-1][0]>=ind:
            callstack.pop()
        if pend is not None and ind==pend[0]:
            rows.append((sec,cont,pend[2],pend[1],kind,name))
            pend=None
        if kind in ('func_call','method_func_call','task_call','method_task_call'):
            callstack.append((ind,name))
        continue
    m=fldre.match(line)
    if m:
        ind=len(m.group(1)); fld=m.group(2)
        pend=None
        if fld in ('vpiFunction','vpiTask'):
            cn = callstack[-1][1] if callstack and callstack[-1][0]<ind else '?'
            pend=(ind,fld,cn)
        continue
for r in rows:
    print('\t'.join(r))
