# r10uvm156 — the MOVER SET, PREDICTED BY NAME from PRISTINE databases only.
# MEASUREMENT ONLY.  A database moves iff it holds a class-handle FUNCTION
# RETURN class_typespec that § 156 will name: currently anonymous, a class_defn
# present, not a builtin.sv class, and the returned class's HOME DESIGN
# COMPONENT differing from the declaring scope's (or both TOP).
import re,sys,collections
RX=re.compile(r'^(\S+) CT (\S+) role=return name=(\S*) inst=(\S*) defn=(\S*) hold=(\S+)@(\d+):(\d+) via=(\S*) dhome=(\S*) ohome=(\S*) chain=(.*)$')
BUILTIN={'work@process','work@mailbox','work@semaphore'}
per=collections.Counter(); cells=collections.Counter()
for path in sys.argv[1:]:
    for ln in open(path):
        m=RX.match(ln.strip())
        if not m: continue
        tag,span,name,inst,defn,hold,hl,hc,via,dh,oh,chain=m.groups()
        if name!='-': continue                       # already named
        if defn=='-' or defn in BUILTIN: continue
        fn=chain.split('<')[0]
        if fn.endswith('(new)') or '::new)' in fn: continue
        if dh==oh and dh!='TOP': continue            # arm B hits: stays anonymous
        per[tag]+=1
        cells[(span.split(':',1)[1],fn,chain.split('<')[1] if '<' in chain else '')]+=1
print(f"PREDICTED MOVERS: {len(per)} databases, {sum(per.values())} cells")
for k,v in sorted(per.items()): print(f"  {v:5d}  {k}")
