#!/usr/bin/env bash
# v98 — three-way score of a DIRECTORY arm (all its .sv/.v compiled together):
# golden(Surelog)=LHS, pristine, candidate.  rc per cell, official uhdm-cmp.
set -u
SRCD=${1:?dir}; MODE=${2:-def}; PRI=${PRI:-/tmp/v98_bin/pris.bin}; PAT=${PAT:?}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
key=$(echo "${SRCD#/tmp/v98_probecopy/probe/}" | sed 's#[^A-Za-z0-9._-]#_#g')_$MODE
D=${DWD:-/tmp/v98_dirwd}/$key; rm -rf "$D"; mkdir -p "$D" || exit 9
leaves=""
for f in "$SRCD"/*.sv "$SRCD"/*.v; do [ -f "$f" ] || continue; cp "$f" "$D/"; leaves="$leaves $(basename "$f")"; done
cd "$D" || exit 9
SLF=""; OF=""; [ "$MODE" = elab ] && { SLF="-elabuhdm"; OF="-elabuhdm"; }
$SURELOG -parse -nocache $SLF $leaves > surelog.log 2>&1 </dev/null
[ -f slpp_all/surelog.uhdm ] || { echo "$key SURELOG_FAIL"; exit 5; }
line="$key"
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" $OF $leaves -o $tag.uhdm > $tag.log 2>&1 </dev/null; rc=$?
  [ -f $tag.uhdm ] || { line="$line | $tag=NO_OUTPUT(rc=$rc)"; continue; }
  if "$CMP" slpp_all/surelog.uhdm $tag.uhdm > $tag.cmp 2>&1; then v=PASS_CMP; else v=CMP_FAIL; fi
  line="$line | $tag rc=$rc $v lines=$(wc -l < $tag.cmp)"
done
echo "$line"
$DUMP slpp_all/surelog.uhdm 2>/dev/null </dev/null | sed 1d > g.dump
$DUMP pris.uhdm 2>/dev/null </dev/null | sed 1d > pris.dump
$DUMP pat.uhdm  2>/dev/null </dev/null | sed 1d > pat.dump
python3 "$(cd "$(dirname "$0")" && pwd)"/v98score.py "$key" g.dump pris.dump pat.dump --nospan
