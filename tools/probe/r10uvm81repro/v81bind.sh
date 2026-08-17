#!/usr/bin/env bash
# r10uvm81 VERIFIER — per-BINDING arm judge.  Runs golden + pristine + patched on
# one .sv in ONE scratch dir, then joins the BIND rows (ref fullname, ref
# line:col) as a MULTISET and reports, for every key:
#   AGREE_PRE   golden==pristine==patched            (untouched, already right)
#   FIXED       golden!=pristine, golden==patched    (a real repair)
#   BROKEN      golden==pristine, golden!=patched    (a REGRESSION -- the thing
#                                                     the verifier exists to find)
#   STILL       golden!=pristine, golden!=patched    (a residue)
#   CHANGED_BOTH_WRONG golden!=pristine!=patched     (moved, still wrong)
# Also reports keys present on only one side.
set -u
SRC=${1:?arm source}
PAT=${PAT:?patched binary}
PRI=${PRI:?pristine binary}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CEN=${CEN:-/tmp/r10uvm81cen}
B=$(basename "$SRC"); B=${B%.*}
D=/tmp/v81_bind_$B
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$LEAF" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; tail -8 surelog.log; exit 5; }
"$PRI" "$LEAF" -o pris.uhdm >pris.log 2>&1 || true
"$PAT" "$LEAF" -o pat.uhdm  >pat.log  2>&1 || true
for f in pris.uhdm pat.uhdm; do
  [ -f "$f" ] || { echo "NO_OUTPUT $B/$f"; tail -5 "${f%.uhdm}.log"; exit 6; }
done
R10UVM81_LIST=1 "$CEN" slpp_all/surelog.uhdm g > g.bind 2>/dev/null
R10UVM81_LIST=1 "$CEN" pris.uhdm p           > p.bind 2>/dev/null
R10UVM81_LIST=1 "$CEN" pat.uhdm  q           > q.bind 2>/dev/null
python3 - "$B" <<'PY'
import sys, collections
name=sys.argv[1]
def load(f):
    d=collections.defaultdict(list)
    for ln in open(f):
        t=ln.split()
        if not t or t[0]!='BIND': continue
        # BIND <tag> <line:col> <refkind> <actualkind> <actual line:col> <reffull> <actualfull>
        key=(t[2], t[6] if len(t)>6 else '')
        val=(t[4], t[5], t[7] if len(t)>7 else '')
        d[key].append(val)
    for k in d: d[k]=sorted(d[k])
    return d
g=load('g.bind'); p=load('p.bind'); q=load('q.bind')
keys=sorted(set(g)|set(p)|set(q))
cnt=collections.Counter()
det=collections.defaultdict(list)
for k in keys:
    gv,pv,qv=g.get(k),p.get(k),q.get(k)
    if gv is None or pv is None or qv is None:
        cnt['ONESIDED']+=1; det['ONESIDED'].append((k,gv,pv,qv)); continue
    if gv==pv==qv: cnt['AGREE_PRE']+=len(gv); continue
    if gv!=pv and gv==qv: cnt['FIXED']+=len(gv); det['FIXED'].append((k,gv,pv,qv)); continue
    if gv==pv and gv!=qv: cnt['BROKEN']+=len(gv); det['BROKEN'].append((k,gv,pv,qv)); continue
    if gv!=pv and gv!=qv and pv==qv: cnt['STILL']+=len(gv); det['STILL'].append((k,gv,pv,qv)); continue
    cnt['CHANGED_BOTH_WRONG']+=len(gv); det['CHANGED_BOTH_WRONG'].append((k,gv,pv,qv))
tot=sum(len(v) for v in g.values())
print(f"ARM {name}: golden bindings={tot} keys={len(g)}")
for c in ('AGREE_PRE','FIXED','BROKEN','STILL','CHANGED_BOTH_WRONG','ONESIDED'):
    print(f"  {c:20s} {cnt[c]}")
for c in ('BROKEN','STILL','CHANGED_BOTH_WRONG','ONESIDED','FIXED'):
    for k,gv,pv,qv in det[c][:60]:
        print(f"  {c} {k[1]} @{k[0]}\n      golden ={gv}\n      pristine={pv}\n      patched ={qv}")
print("VERDICT:", "REGRESSION" if cnt['BROKEN'] else "no regression")
PY
echo "WD=$D"
