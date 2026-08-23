import sys, importlib.util
spec = importlib.util.spec_from_file_location(
    "s112", "/tmp/wt_r10uvm112/tools/probe/r10uvm112repro/score112.py")
# reuse cen() without running the __main__ comparison
src = open("/tmp/wt_r10uvm112/tools/probe/r10uvm112repro/score112.py").read()
src = src.split("a, b = cen(")[0]
ns = {}
exec(src, ns)
cen = ns['cen']
g = cen(sys.argv[1]); p = cen(sys.argv[2]); s = cen(sys.argv[3])
def state(ours, gold):
    # NAME-only containment: does every actual we bind appear in golden's set?
    on = {x[1] for x in ours}; gn = {x[1] for x in gold}
    return on <= gn
tog=away=stillwrong=stillright=0
for k in sorted(set(g) & set(p) & set(s)):
    bp, bs = state(p[k], g[k]), state(s[k], g[k])
    if not bp and bs: tog += 1;        print('TO-GOLDEN   %s : %s -> %s' % (k, sorted({x[1] for x in p[k]}), sorted({x[1] for x in s[k]})))
    elif bp and not bs: away += 1;     print('AWAY-GOLDEN %s : %s -> %s' % (k, sorted({x[1] for x in p[k]}), sorted({x[1] for x in s[k]})))
    elif not bp and not bs: stillwrong += 1
    else: stillright += 1
print('--- TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG=%d STILL-RIGHT=%d'
      % (tog, away, stillwrong, stillright))
