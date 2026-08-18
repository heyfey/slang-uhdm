#!/usr/bin/env bash
# v98 verifier arm runner.  Scratch keyed on the RELATIVE path.  rc per cell.
# Judge = the OFFICIAL uhdm-cmp.  LHS = golden.
set -u
SRC=${1:?arm}; ROOT=${ROOT:-$(cd "$(dirname "$0")" && pwd)}
PRI=${PRI:-/tmp/v98_bin/pris.bin}; PAT=${PAT:-/tmp/v98_bin/pat.bin}
MODE=${MODE:-def}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
rel=${SRC#$ROOT/}
key=$(echo "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')_$MODE
D=${AWD:-/tmp/v98_armwd}/$key
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
leaf=$(basename "$SRC")
cd "$D" || exit 9
SLF=""; OF=""
if [ "$MODE" = elab ]; then SLF="-elabuhdm"; OF="-elabuhdm"; fi
"$SURELOG" -parse -nocache $SLF "$leaf" > surelog.log 2>&1 </dev/null; echo $? > sl.rc
if [ ! -f slpp_all/surelog.uhdm ]; then echo "$key SURELOG_FAIL(rc=$(cat sl.rc))"; exit 5; fi
line="$key"
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" $OF "$leaf" -o $tag.uhdm > $tag.log 2>&1 </dev/null; rc=$?; echo $rc > $tag.rc
  if [ ! -f $tag.uhdm ]; then line="$line | $tag=NO_OUTPUT(rc=$rc)"; continue; fi
  if "$CMP" slpp_all/surelog.uhdm $tag.uhdm > $tag.cmp 2>&1; then v=PASS; else v=FAIL; fi
  line="$line | $tag rc=$rc $v heads=$(grep -c '^LHS:' $tag.cmp; true) lines=$(wc -l < $tag.cmp)"
done
echo "$line"
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
$DUMP slpp_all/surelog.uhdm 2>/dev/null </dev/null | sed 1d > g.dump
$DUMP pris.uhdm 2>/dev/null </dev/null | sed 1d > pris.dump
$DUMP pat.uhdm  2>/dev/null </dev/null | sed 1d > pat.dump
python3 "$(cd "$(dirname "$0")" && pwd)"/v98score.py "$key" g.dump pris.dump pat.dump
python3 "$(cd "$(dirname "$0")" && pwd)"/v98score.py "$key/NOSPAN" g.dump pris.dump pat.dump --nospan
