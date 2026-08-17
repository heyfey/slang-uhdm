#!/usr/bin/env bash
# multi-file variant of run3.sh: all sources named, first arg is the label
set -u
LAB=${1:?label}; VIEW=${2:?view}; ROOT=${3:?outroot}; shift 3
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
PAT=${PAT:?set PAT to the patched binary}; PRIS=${PRIS:?set PRIS to the pristine binary}
case $VIEW in plain) SLF="--single-unit"; SUF="-parse";;
              elab)  SLF="--single-unit --elabuhdm"; SUF="-parse -elabuhdm";; esac
D="$ROOT/${LAB}_$VIEW"; rm -rf "$D"; mkdir -p "$D/g" "$D/pris" "$D/pat"
NAMES=""; for s in "$@"; do for t in g pris pat; do cp "$s" "$D/$t/"; done; NAMES="$NAMES $(basename $s)"; done
( cd "$D/g" && $SURELOG $SUF -nocache -mt 0 -mp 0 $NAMES >surelog.log 2>&1 )
[ -f "$D/g/slpp_all/surelog.uhdm" ] || { echo "$LAB SURELOG_FAIL"; tail -5 "$D/g/surelog.log"; exit 5; }
$DUMP "$D/g/slpp_all/surelog.uhdm" 2>/dev/null | sed 1d | sed "s#$D/g#WD#g" > "$D/g.dump"
for s in pris pat; do case $s in pris) BIN=$PRIS;; pat) BIN=$PAT;; esac
  ( cd "$D/$s" && $BIN $SLF $NAMES -o slang.uhdm >slang.log 2>&1 )
  [ -f "$D/$s/slang.uhdm" ] || { echo "$LAB NO_OUTPUT($s)"; tail -5 "$D/$s/slang.log"; exit 6; }
  $DUMP "$D/$s/slang.uhdm" 2>/dev/null | sed 1d | sed "s#$D/$s#WD#g" > "$D/$s.dump"
  $CMP "$D/g/slpp_all/surelog.uhdm" "$D/$s/slang.uhdm" > "$D/cmp_$s.log" 2>&1
done
printf '%-10s %-5s cmpheads pris=%s pat=%s | pris-vs-pat=%s\n' "$LAB" "$VIEW" \
  "$(grep -c '^LHS:' $D/cmp_pris.log; true)" "$(grep -c '^LHS:' $D/cmp_pat.log; true)" \
  "$(cmp -s $D/pris.dump $D/pat.dump && echo SAME || echo DIFF)"
