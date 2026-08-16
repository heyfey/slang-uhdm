import re,sys,collections
def nets(path):
    out=[]
    prev=None
    with open(path,errors='replace') as f:
        for ln in f:
            if prev is not None and prev.rstrip('\n')=='  |vpiNet:':
                m=re.match(r'^  \\_(\w+): \(([^)]*)\), line:(\d+):(\d+), endln:(\d+):(\d+)',ln)
                if m: out.append((m.group(1),m.group(2),m.group(3)+':'+m.group(4),m.group(5)+':'+m.group(6)))
                else:
                    m2=re.match(r'^  \\_(\w+): \(([^)]*)\)',ln)
                    if m2: out.append((m2.group(1),m2.group(2),'-','-'))
            prev=ln
    return out
g=nets(sys.argv[1]); o=nets(sys.argv[2])
print("GOLDEN nets=%d  OURS nets=%d"%(len(g),len(o)))
gn=[x[1] for x in g]; on=[x[1] for x in o]
cg=collections.Counter(gn); co=collections.Counter(on)
print("-- names GOLDEN-only (by multiset):")
for k in sorted((cg-co).elements()): print("   +",k, [x for x in g if x[1]==k][0])
print("-- names OURS-only (by multiset):")
for k in sorted((co-cg).elements()): print("   -",k, [x for x in o if x[1]==k][0])
# span disagreements on shared names
print("-- shared names with SPAN/KIND disagreement:")
gm={x[1]:x for x in g}; om={x[1]:x for x in o}
n=0
for k in sorted(set(gm)&set(om)):
    if gm[k][0]!=om[k][0] or gm[k][2]!=om[k][2] or gm[k][3]!=om[k][3]:
        print("   ",k,"G",gm[k],"O",om[k]); n+=1
print("   disagreeing=%d"%n)
# order
print("-- ORDER: first index where names differ:")
for i in range(min(len(gn),len(on))):
    if gn[i]!=on[i]:
        print("   idx",i,"G",gn[i],"O",on[i]); break
else: print("   prefix identical up to",min(len(gn),len(on)))
