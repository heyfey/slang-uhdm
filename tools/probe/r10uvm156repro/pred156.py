# r10uvm156 — SCORE THE PREDICATE AGAINST GOLDEN'S OWN NAMING, before any code.
# MEASUREMENT ONLY.  LHS IS ALWAYS GOLDEN.
#
# § classHandleRetTsNameUnlessSameHomeComponent156, as a predicate over a
# ct156cen census of a GOLDEN database: a class-handle FUNCTION-RETURN
# class_typespec is ANONYMOUS iff the returned class's HOME DESIGN COMPONENT is
# the declaring scope's and that home is not TOP ($unit / an interface).
# Three populations are FENCED OUT, exactly as the production predicate fences
# them, and the fence sizes are printed so the scope is auditable:
#   * a CONSTRUCTOR (`new`) — a different mint site and a different rule;
#   * a builtin.sv class (`process` / `mailbox` / `semaphore`) — Surelog
#     registers those under their BARE name, so arm B hits from anywhere;
#   * an ALIAS-NAMED cell, i.e. one whose VpiName is not the class's own name
#     (`type_id`, `this_type`) — a return written through a TYPEDEF or a type
#     parameter, Surelog's arm A.
#   usage: pred156.py <dir of *.G.txt censuses>
import re,collections,sys,glob,os
RX=re.compile(r'^\S+ CT (\S+) role=(\S+) name=(\S*) inst=(\S*) defn=(\S*) '
              r'hold=(\S+)@(\d+):(\d+) via=(\S*) dhome=(\S*) ohome=(\S*) chain=(.*)$')
BUILTIN={'work@process','work@mailbox','work@semaphore'}
tot=collections.Counter(); bad=[]
for gp in sorted(glob.glob(sys.argv[1]+'/*.G.txt')):
    row=os.path.basename(gp)[:-6]
    c=collections.Counter()
    for ln in open(gp):
        m=RX.match(ln.strip())
        if not m: continue
        span,role,name,inst,defn,hold,hl,hc,via,dh,oh,chain=m.groups()
        if role!='return': continue
        fn=chain.split('<')[0]
        if fn.endswith('(new)') or '::new)' in fn: c['fence:new']+=1; continue
        if defn in BUILTIN:                        c['fence:builtin']+=1; continue
        short=defn.split('::')[-1]
        if name!='-' and not (name==short or name.endswith('::'+short)):
            c['fence:alias']+=1; continue
        ok=((dh==oh and dh!='TOP')==(name=='-'))
        c['OK' if ok else 'MISS']+=1
        if not ok: bad.append((row,span,name,dh,oh,chain[:80]))
    print(f"{row:26s} " + "  ".join(f"{k}={v}" for k,v in sorted(c.items())))
    tot.update(c)
print("TOTAL", dict(tot))
for b in bad[:30]: print("  MISS",b)
