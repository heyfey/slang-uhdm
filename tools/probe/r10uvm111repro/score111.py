# score111.py — TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG scorer for the pass.
# Reads ct111id CALL rows (golden, pristine, patched) for one database and
# scores each (view, package, variable, call) cell by the SHAPE of the binding,
# because the two candidate objects are distinguishable by shape and not by any
# id that is comparable across producers:
#     PKGLIST  the callee is the package's own `C::m` Task_funcs entry
#              (its VpiName is the FULL `C::m` spelling)
#     CLASSM   the callee is the class_defn's method (VpiName = `m` only)
#     NONE     no vpiFunction
import subprocess, sys, os
CT = "/tmp/r10uvm111_scratch/ct111id"
env = dict(os.environ, LD_LIBRARY_PATH=os.path.expanduser("~/.local/lib64")+":"+os.path.expanduser("~/.local/lib"))
def cells(db):
    out = subprocess.run([CT, db, "::"], capture_output=True, text=True, env=env).stdout
    d = {}
    for l in out.splitlines():
        if not l.startswith("CALL "):
            continue
        f = l.split()
        view = f[1]
        pkg = f[2].split("=")[1].split("#")[0]
        var = f[3].split("=",1)[1]
        call = f[4].split("=",1)[1]
        fname = f[6].split("=",1)[1]
        shape = "NONE" if fname == "<null>" else ("PKGLIST" if fname == call else "CLASSM")
        d[(view,pkg,var,call)] = shape
    return d
g, p, q = cells(sys.argv[1]), cells(sys.argv[2]), cells(sys.argv[3])   # golden, pristine, patched
tg=aw=sw=ok=0
for k in sorted(set(g)|set(p)|set(q)):
    G,P,Q = g.get(k,"-"), p.get(k,"-"), q.get(k,"-")
    if P==G and Q==G: ok+=1; tag="ALREADY-RIGHT"
    elif P!=G and Q==G: tg+=1; tag="TO-GOLDEN"
    elif P==G and Q!=G: aw+=1; tag="AWAY-GOLDEN"
    elif P!=G and Q!=G: sw+=1; tag="STILL-WRONG"
    print("%-13s %-4s %-14s %-10s %-16s G=%-8s PRIS=%-8s PAT=%s" % (tag,k[0],k[1],k[2],k[3],G,P,Q))
print("SCORE tests=%d TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG=%d ALREADY-RIGHT=%d" % (len(set(g)|set(p)|set(q)), tg, aw, sw, ok))
