#!/usr/bin/env bash
# r10uvm117repro/attrib117.sh — BOUNDARY-ARM ATTRIBUTION.  For every arm the
# boundary gate reported as differing, build the GOLDEN (Surelog) database for
# the same file and print, per changed reference cell, golden's answer next to
# the pristine and the patched one — so an arm that MOVED can be shown to have
# moved TO GOLDEN and not away.  MEASUREMENT ONLY.
#
#   attrib117.sh <differ.txt> <probe root> <pristine> <patched> <workdir> <cen>
#
# Every command records its own rc into <workdir>/cmds.txt.
# VIEW=def (default) | elab -- run it in BOTH, exactly as the boundary gate is.
set -u
D=${1:?differ.txt}; ROOT=${2:?root}; P=${3:?pristine}; Q=${4:?patched}
W=${5:?workdir}; CEN=${6:?cen}
VIEW=${VIEW:-def}
EF=""; SF=""
[ "$VIEW" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
SL=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$W"; : > "$W/cmds.txt"
while IFS= read -r rel; do
  case "$rel" in ''|'-- differing arms:'|BOUND*) continue;; esac
  key=$(printf '%s' "$rel" | sed 's#^\./##; s#/#__#g; s#\.\(sv\|v\)$##')
  d="$W/$key"; mkdir -p "$d"
  ( cd "$d" && "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm \
        $SF -o "$d/g" "$ROOT/$rel" >sl.log 2>&1; echo "rc=$? surelog $rel" >> "$W/cmds.txt" ) </dev/null
  ( cd "$d" && "$P" "$ROOT/$rel" $EF -o p.uhdm >p.log 2>&1; echo "rc=$? pristine $rel" >> "$W/cmds.txt" ) </dev/null
  ( cd "$d" && "$Q" "$ROOT/$rel" $EF -o q.uhdm >q.log 2>&1; echo "rc=$? patched  $rel" >> "$W/cmds.txt" ) </dev/null
  G="$d/g/slpp_all/surelog.uhdm"
  if [ ! -f "$G" ] || [ ! -s "$d/p.uhdm" ] || [ ! -s "$d/q.uhdm" ]; then
    echo "== $rel  SKIP (golden=$( [ -f "$G" ] && echo ok || echo MISSING ))"; continue
  fi
  "$CEN" "$G" G > "$d/cen.g" 2>/dev/null
  "$CEN" "$d/p.uhdm" O > "$d/cen.p" 2>/dev/null
  "$CEN" "$d/q.uhdm" O > "$d/cen.q" 2>/dev/null
  echo "== $rel"
  python3 - "$d/cen.g" "$d/cen.p" "$d/cen.q" <<'PY'
import sys, collections
def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        # ct117cen's REF layout: 2 VIEW 3 OOB 4 HOME 5 OWNER 6 SPAN 7 NAME
        # 8 ACT ... (one column MORE than r10uvm109cen's, so the indices are
        # NOT that script's).  Key on what both producers can spell; the value
        # is the ACTUAL's KIND.
        if len(f) >= 14 and f[1] == 'REF':
            d[(f[2], f[4], f[5], f[6], f[7])][f[8]] += 1
        # and the implicit NETS, which is where this law's own move shows.
        elif len(f) >= 9 and f[1] == 'NET' and f[3] == 'IMPL':
            d[('NET', f[2], f[4], f[5], f[6])][f[6]] += 1
    return d
G, A, B = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
tg = aw = st = 0
for k in sorted(set(A) | set(B)):
    if A[k] == B[k]: continue
    g = dict(G[k]) if k in G else 'ABSENT'
    verdict = 'TO-GOLDEN' if (k in G and B[k] == G[k]) else \
              ('AWAY' if (k in G and A[k] == G[k]) else 'OTHER')
    if verdict == 'TO-GOLDEN': tg += 1
    elif verdict == 'AWAY': aw += 1
    else: st += 1
    print('   %-9s %s %s %s %s %s : pris=%s pat=%s golden=%s'
          % (verdict, k[0], k[1], k[2], k[3], k[4], dict(A[k]), dict(B[k]), g))
print('   -> TO-GOLDEN=%d AWAY=%d OTHER=%d' % (tg, aw, st))
PY
done < "$D"
