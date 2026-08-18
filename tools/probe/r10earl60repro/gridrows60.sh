#!/usr/bin/env bash
# r10earl60 — one-line-per-param_assign grid printer for an arm workdir.
# Runs pacensus60 on BOTH databases of an arm and prints the joined rows.
#   usage: gridrows60.sh <armdir> [pacensus60-path]
set -u
D=${1:?armdir}
PA=${2:-/tmp/r10earl60_s/pacensus60}
[ -x "$PA" ] || { echo "FATAL: no pacensus60 at $PA"; exit 9; }
[ -f "$D/slpp_all/surelog.uhdm" ] || { echo "FATAL: no golden db in $D"; exit 9; }
[ -f "$D/slang.uhdm" ] || { echo "FATAL: no ours db in $D"; exit 9; }
"$PA" "$D/slpp_all/surelog.uhdm" "$D/g.pa" >/dev/null || exit 9
"$PA" "$D/slang.uhdm" "$D/o.pa" >/dev/null || exit 9
python3 - "$D" <<'PY'
import re, sys
D=sys.argv[1]
def nospan(s): return re.sub(r'^[^:]*:', '', s)
def load(p):
    d={}
    for l in open(p):
        f=l.rstrip('\n').split('\t')
        d[(f[0],f[1],f[2],nospan(f[3]))]=(f[4],f[6],nospan(f[7]),f[8],f[9])
    return d
g=load(D+'/g.pa'); o=load(D+'/o.pa')
n=0
for k in sorted(set(g)|set(o)):
    a=g.get(k); b=o.get(k)
    v='SAME' if a==b else 'DIFFER'
    if v=='DIFFER': n+=1
    print('%-5s %-20s %-12s %-12s | %-40s | %-40s %s'%(k[0],k[1],k[2],k[3],
          '/'.join(a) if a else 'KEY-ONLY-OURS','/'.join(b) if b else 'KEY-ONLY-GOLD',v))
print('ROWS=%d DIFFERING=%d'%(len(set(g)|set(o)),n))
PY
