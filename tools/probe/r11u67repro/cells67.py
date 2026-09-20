import sys, subprocess, collections, os
NT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'r11v65repro', 'nettype65.py')
def rd(p):
    out = subprocess.run(['python3',NT,p],capture_output=True,text=True).stdout
    m = collections.defaultdict(list)
    for l in out.split('\n'):
        if not l: continue
        k, nt = l.rsplit('|NT=',1)
        m[k].append(int(nt))
    return {k:sorted(v) for k,v in m.items()}
d=sys.argv[1]; tags=sys.argv[2:]
g = rd(d+'/gold.pris.dump')
outs = {t: rd(d+'/ours.%s.dump'%t) for t in tags}
keys = sorted(set(g) | set().union(*[set(o) for o in outs.values()]))
for k in keys:
    row = [str(g.get(k))] + [str(outs[t].get(k)) for t in tags]
    flag = '' if all(r==row[0] for r in row[1:]) else '   <<<'
    print('%-62s gold=%-8s %s%s' % (k, row[0], ' '.join('%s=%s'%(t,r) for t,r in zip(tags,row[1:])), flag))
