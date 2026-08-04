import re, sys
def parse(p):
    out=[]; cur=None; view=0
    for ln in open(p):
        if 'Restored design' in ln: pass
        m=re.search(r'\\_param_assign: , line:(\d+):(\d+)', ln)
        if m: cur=m.group(1)+':'+m.group(2)
        m=re.search(r'\|vpiDecompile:(.*)$', ln)
        if m: out.append([cur, m.group(1).rstrip(), None])
        m=re.search(r'\|vpiSize:(-?\d+)', ln)
        if m and out and out[-1][2] is None: out[-1][2]=m.group(1)
    return [x for x in out if x[2] is not None and x[0]]
for p in sys.argv[1:]:
    print('#####', p)
    groups={}
    order=[]
    for pa,dec,sz in parse(p):
        k=pa
        if k not in groups: groups[k]=[]; order.append(k)
        groups[k].append(dec+'/'+sz)
    for k in order:
        print('  %-8s %s' % (k, ' '.join(groups[k])))
