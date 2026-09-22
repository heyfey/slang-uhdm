import sys, importlib.util
spec = importlib.util.spec_from_file_location("n", "/tmp/r11u97_g/nda97.py")
# reuse read() without running main
src = open('/tmp/r11u97_g/nda97.py').read().replace('main()\n','',1)
ns = {}
exec(compile(src, 'nda97', 'exec'), ns)
read = ns['read']
g = read(sys.argv[1]); a = read(sys.argv[2])
only = sys.argv[3] if len(sys.argv)>3 else None
for n in g:
    G=g[n]; A=a.get(n,{'kind':'MISSING'})
    def f(x):
        if x.get('kind')!='constant': return f"<{x.get('kind')}>"
        return f"{x['v']} ct{x['ct']} sz{x['sz']} d[{x['d']}]"
    eq = 'EQ ' if f(G)==f(A) else '** '
    if only=='diff' and eq=='EQ ': continue
    print(f"{eq}{n:9s} G: {f(G):<34s} P: {f(A)}")
