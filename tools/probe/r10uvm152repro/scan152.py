import sys, re, collections
# Scan a uhdm-dump for  ref_obj (NAME), line:L:C ... |vpiActual: \_<kind>: (TARGET), line:..
# Emit one row per (ref fullname, ref span) -> (target kind, target name, target span).
ref_re = re.compile(r'^(\s*)\\_(ref_obj|hier_path): \(([^)]*)\)(, line:(\d+):(\d+), endln:(\d+):(\d+))?')
act_re = re.compile(r'^(\s*)\|vpiActual:')
obj_re = re.compile(r'^(\s*)\\_([a-z_]+): (\(([^)]*)\))?(, line:(\d+):(\d+), endln:(\d+):(\d+))?')
def scan(path):
    rows=[]
    lines=open(path,encoding='utf-8',errors='replace').read().split('\n')
    cur=None
    for i,l in enumerate(lines):
        m=ref_re.match(l)
        if m:
            cur=(m.group(3), m.group(5), m.group(6), len(m.group(1)))
            continue
        m=act_re.match(l)
        if m and cur:
            ind=len(m.group(1))
            if ind != cur[3]+2: continue
            m2=obj_re.match(lines[i+1]) if i+1<len(lines) else None
            if m2:
                rows.append((cur[0],cur[1],cur[2],m2.group(2),m2.group(4),m2.group(6),m2.group(7)))
    return rows
rows=scan(sys.argv[1])
if len(sys.argv)>2 and sys.argv[2]=='--dedup':
    seen=set(); out=[]
    for r in rows:
        if r in seen: continue
        seen.add(r); out.append(r)
    rows=out
for r in rows: print('\t'.join('' if x is None else str(x) for x in r))
