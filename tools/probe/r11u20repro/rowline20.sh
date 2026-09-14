#!/usr/bin/env bash
# Per-LINE directional census for a NAMED SWEEP ROW, against that row's OWN
# golden, ORDER-BLIND (sorted, workdir-path normalised).
#
# BLINDNESS, STATED UP FRONT: this census is MISLEADING for both of this pass's
# laws and the KEYED cen20.py is the measurement.  § typeParamDefaultBound-
# NoReduce20 turns ONE constant into an operation tree, so every generic line
# (`|vpiParent:`, `|vpiOperand:`, `|vpiConstType:9`, `|UINT:1`) multiplies on
# each object we carry that golden does not — the per-view duplicate typespec
# and the elaborated instance copies golden never emits — and the folded
# constants the law removes are counted against unrelated `UINT:<n>` lines
# elsewhere in the design (the multiset trap).
#   usage: PRIS=<workdir> PAT=<workdir> rowline20.sh <mode> <name>...
set -u
P=${PRIS:?pristine workdir root}
Q=${PAT:?patched workdir root}
M=${1:?mode}; shift
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
T=$(mktemp -d /tmp/r11u20_rowline.XXXXXX)
trap 'rm -rf "$T"' EXIT
for n in "$@"; do
  pd=$(ls -d "$P/$M/$n"-* 2>/dev/null | head -1)
  qd=$(ls -d "$Q/$M/$n"-* 2>/dev/null | head -1)
  { [ -z "$pd" ] || [ -z "$qd" ]; } && { echo "$n MISSING-ROW"; continue; }
  gold=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$pd/cmds.txt" | head -1)
  g=$(find "$gold" \( -name golden.uhdm -o -name surelog.uhdm \) 2>/dev/null | head -1)
  [ -z "$g" ] && { echo "$n NO-GOLDEN"; continue; }
  "$UD" "$g"             2>/dev/null | sed 's#/tmp/[^ ,)]*##g; s/^ *//' | sort > "$T/g"
  "$UD" "$pd/slang.uhdm" 2>/dev/null | sed 's#/tmp/[^ ,)]*##g; s/^ *//' | sort > "$T/p"
  "$UD" "$qd/slang.uhdm" 2>/dev/null | sed 's#/tmp/[^ ,)]*##g; s/^ *//' | sort > "$T/q"
  python3 - "$n" "$M" "$T" <<'PY'
import sys, collections
n, m, T = sys.argv[1], sys.argv[2], sys.argv[3]
def mc(p):
    c = collections.Counter()
    for l in open(p, errors='replace'): c[l.rstrip('\n')] += 1
    return c
g, p, q = mc(T+'/g'), mc(T+'/p'), mc(T+'/q')
to = away = 0; away_l = []
for k in set(g) | set(p) | set(q):
    gp, gq = abs(g[k]-p[k]), abs(g[k]-q[k])
    if gq < gp: to += 1
    elif gq > gp: away += 1; away_l.append((k, g[k], p[k], q[k]))
print("%-34s [%s] TO-GOLDEN=%d AWAY-GOLDEN=%d" % (n, m, to, away))
for k, a, b, c in away_l[:20]:
    print("   AWAY g=%d pris=%d pat=%d | %s" % (a, b, c, k[:120]))
PY
done
