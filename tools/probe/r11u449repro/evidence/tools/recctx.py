import sys
f=sys.argv[1]; ns=[int(x) for x in sys.argv[2:]]
lines=open(f).read().split('\n')
for n in ns:
    l=lines[n-1]; d=int(l.split('\t')[0]); out=[l]
    for i in range(n-2,-1,-1):
        try: di=int(lines[i].split('\t')[0])
        except: continue
        if di<d: out.append(lines[i]); d=di
        if d<=0: break
    print('== #%d'%n)
    for o in reversed(out): print('  '+'\t'.join(o.split('\t')[:9])[:160])
