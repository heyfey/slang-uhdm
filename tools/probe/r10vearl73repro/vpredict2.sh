#!/usr/bin/env bash
# r10v73 stage 2 — of the stage-1 candidates, which carry the LAW'S OWN shape:
# a param_assign Rhs constant where golden is ct=7 (INT) and ours ct=9 (UINT)
# with the SAME digits (or vice versa)?  Predicted movers = these, by name.
set -u
WD=$1; CAND=$2; CEN=/tmp/v73_bin/pacen73
grep '^CANDIDATE ' "$CAND" | awk '{print $2}' | while read -r rel; do
  d="$WD/$rel"; c="$d/cmds.txt"
  g=$(grep -oE '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]+' "$c" | head -1)
  [ -f "$g/golden.uhdm" ] || continue
  n=$(python3 - "$g/golden.uhdm" "$d/slang.uhdm" <<'PY'
import subprocess,sys,collections,re
def load(p):
    d=collections.defaultdict(list)
    out=subprocess.run(['/tmp/v73_bin/pacen73',p],capture_output=True,text=True).stdout
    for ln in out.splitlines():
        if not ln.startswith('PA '): continue
        f=ln.split(' ')
        d[(f[1],f[2])].append(' '.join(f[3:]))
    for k in d: d[k].sort()
    return d
G,O=load(sys.argv[1]),load(sys.argv[2])
n=0
for k in G:
    if k not in O: continue
    for a,b in zip(G[k],O[k]):
        if a==b: continue
        ga=re.search(r'ct=(\d+) sz=(\d+) val=(\w+):(\S*)',a); ob=re.search(r'ct=(\d+) sz=(\d+) val=(\w+):(\S*)',b)
        if not ga or not ob: continue
        if {ga.group(1),ob.group(1)}=={'7','9'} and ga.group(4)==ob.group(4):
            n+=1
print(n)
PY
)
  [ "${n:-0}" -gt 0 ] && echo "PREDICT-MOVER $rel cells=$n"
done
