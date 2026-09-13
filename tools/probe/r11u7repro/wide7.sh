#!/bin/bash
# r11u7 WIDE BOUNDARY — compile every committed interface probe arm with both
# binaries against its own REAL Surelog v1.87 golden; report every arm whose
# database bytes move, with the official uhdm-cmp rc + LHS head count per arm.
# ASSERTS that every listed arm actually PRODUCED two databases (an arm that
# compiled nothing reads green and means nothing).
set -u
P=${1:?pristine}; Q=${2:?patched}; R=${3:?armroot}
# r11v7 — both paths resolve BESIDE THIS SCRIPT by default.  The shipped
# default used to be a hard-coded `/tmp/wt_<pass>` worktree, which does not
# exist for any other operator: the first run of this gate then found no
# armrun.sh (or, worse, one that built nothing) and printed a green MOVED=0
# over an empty set.  `ARMRUN=` and `ARMROOT=` still override.
SELF=$(dirname "$(readlink -f "$0")")
H=${ARMROOT:-$(dirname "$SELF")}
RUN=${ARMRUN:-$SELF/armrun.sh}
[ -f "$RUN" ] || { echo "FATAL: no armrun.sh at $RUN"; exit 2; }
AR=$(cd $H && for d in r11u1repro r11u3repro r11u4repro r11u5repro r11v1repro r11v4repro r11vu3repro r11v11u5repro; do find $d -name '*.sv' -printf '%h\n' 2>/dev/null; done | sort -u)
listed=$(echo "$AR" | wc -w)
n=0; built=0; moved=0
mkdir -p "$R"; : > "$R/run.txt"
for a in $AR; do
  n=$((n+1))
  tag=$(echo "$a" | tr '/' '_')
  mkdir -p "$R/$tag"; cp "$H/$a"/*.sv "$R/$tag/"
  bash "$RUN" "$R/$tag" pris "$P" >> "$R/run.txt" 2>&1
  bash "$RUN" "$R/$tag" pat  "$Q" >> "$R/run.txt" 2>&1
  fa="$R/$tag/w_pris/slang.uhdm"; fb="$R/$tag/w_pat/slang.uhdm"
  if [ -f "$fa" ] && [ -f "$fb" ]; then
    built=$((built+1))
    ma=$(md5sum < "$fa" | cut -d' ' -f1); mb=$(md5sum < "$fb" | cut -d' ' -f1)
    [ "$ma" = "$mb" ] || { moved=$((moved+1)); echo "MOVED $tag"; }
  else
    echo "NO-DATABASE $tag"
  fi
done
echo "ARMS_LISTED=$listed ARMS_PROCESSED=$n ARMS_WITH_TWO_DATABASES=$built MOVED=$moved"
