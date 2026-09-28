#!/bin/bash
# r11u196: per-law attribution on named corpus row-modes.  For each row-mode and each switch state, runs the law binary
# with the pristine sweep's command line and cwd, then the strict comparator against the row's golden: prints the strict
# verdict line and the order-blind strict-record distance (dist = ours-not-in-golden, miss = golden-not-in-ours).
# usage: attrib.sh <pristine sweep workdir> "<row>:<mode> ..." "<STATE> ..."   (a STATE is `none` or VAR=1[,VAR=1])
# (fence: refuses fenced rows, fail closed)
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 3
W=$1; ROWS=$2; STATES=$3; O=/tmp/r11u196_attrib; mkdir -p $O
one() { local t=$1 m=$2 st=$3
  r196_fenced "$t" && { echo "attrib.sh: fenced row refused"; return; }
  local d=$(ls -d $W/surelog/$m/$t-* $W/uhdm2rtlil/$m/$t-* 2>/dev/null | head -1)
  local args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S*\.bin ##; s# -o \S*$##')
  local cwd=$(grep -o 'cwd: *[^ ]*' $d/cmds.txt | head -1 | awk '{print $2}')
  [ -z "$cwd" ] && cwd=$(cd $R196_REPO && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])" 2>/dev/null)
  local g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}'); local gu=$(find $g -name '*.uhdm' | head -1)
  local e=""; [ "$st" != none ] && e=$(echo $st | tr ',' ' ')
  local o=$O/${t}_${m}_$(echo $st | tr ',=' '__').uhdm; rm -f $o
  (cd $cwd && eval "env $e $R196_BIN/law.bin $args -o $o" > $o.log 2>&1)
  $SCMP --max 0 --dump-a $o.a --dump-b $o.b $gu $o > $o.strict 2>&1
  local dm=$(python3 - $o.a $o.b <<'PY'
import sys, collections
a = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[1]) if '\t' in l)
b = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[2]) if '\t' in l)
print('dist=%d miss=%d' % (sum((b - a).values()), sum((a - b).values())))
PY
)
  echo "$t $m $st $(grep -m1 -E '^(STRICT_|NOT_EQUAL)' $o.strict) $dm"; rm -f $o.a $o.b; }
export -f one r196_fenced; export W O
for rm in $ROWS; do for st in $STATES; do echo "${rm%%:*} ${rm##*:} $st"; done; done | xargs -P 3 -L 1 bash -c 'one $0 $1 $2'
