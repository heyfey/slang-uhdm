import sys,os,difflib
src=open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'score2.py')).read(); src=src[:src.rindex('\nmain()')]
ns={}; exec(compile(src,'score2','exec'),ns); load=ns['load']
d=sys.argv[1]
for sfx,view in (('','def'),('e','elab')):
    g=load(os.path.join(d,'g%s.dump'%sfx),d); o=load(os.path.join(d,'o%s.dump'%sfx),d); q=load(os.path.join(d,'q%s.dump'%sfx),d)
    if g is None or o is None or q is None: print(d,view,'SKIP'); continue
    def dl(a,b): return sum(1 for l in difflib.unified_diff([x.strip() for x in a],[x.strip() for x in b],n=0) if l[:1] in '+-' and l[:3] not in ('+++','---'))
    print('%-10s %-5s golden-vs-pris=%-6d golden-vs-patched=%-6d pris-vs-patched=%d'%(os.path.basename(d),view,dl(g,o),dl(g,q),dl(o,q)))
