#!/usr/bin/env bash
# r10oth4 -- print the ARM TABLE for a workdir produced by rarm.sh: one row per
# folded cont_assign / procedural-assignment / port constant, GOLDEN and OURS
# side by side, with the digit count.  Reads g.dump / o.dump only, so it can be
# re-run on an old workdir without recompiling.
#
#   usage: ./rtab.sh /tmp/r10oth4_arm_r1_repl
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# POSITIVE CONTROL: exits 3 if either side yields no rows at all -- a table that
# cannot find its probe must not print "no differences".
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
D=${1:?usage: rtab.sh <workdir>}
[ -f "$D/g.dump" ] && [ -f "$D/o.dump" ] || { echo NO_DUMPS; exit 6; }
FILT='cont_assign:vpiRhs|:vpiRhs$|port:vpiHighConn|assignment'
for side in g o; do
  python3 "$HERE/replform.py" "$D/$side.dump" \
    | grep -E "$FILT" | grep -v ':vpiParent' > "$D/$side.tab"
done
gn=$(wc -l < "$D/g.tab"); on=$(wc -l < "$D/o.tab")
[ "$gn" -gt 0 ] && [ "$on" -gt 0 ] || { echo "TABLE_BLIND g=$gn o=$on"; exit 3; }
echo "rows: golden(LHS)=$gn ours(RHS)=$on"
# join on (view,module) so a size/digit difference shows on one line
python3 - "$D/g.tab" "$D/o.tab" <<'PY'
import sys
def rd(p):
    r=[]
    for l in open(p):
        f=l.split()
        r.append((f[0],f[1],' '.join(f[4:])))
    return r
g,o=rd(sys.argv[1]),rd(sys.argv[2])
gk={}
for v,m,rest in g: gk.setdefault((v,m),[]).append(rest)
ok={}
for v,m,rest in o: ok.setdefault((v,m),[]).append(rest)
keys=sorted(set(gk)|set(ok))
diff=0
for k in keys:
    a=gk.get(k,[]); b=ok.get(k,[])
    for i in range(max(len(a),len(b))):
        x=a[i] if i<len(a) else '<MISSING>'
        y=b[i] if i<len(b) else '<MISSING>'
        mark='   ' if x==y else '***'
        if x!=y: diff+=1
        print('%s %-4s %-14s G| %-70s\n%s %-4s %-14s O| %s'%(mark,k[0],k[1],x,mark,k[0],k[1],y))
print('DIFFERING CELLS: %d'%diff)
PY
