#!/bin/bash
# v11u210: judge one case dir against the pinned Surelog v1.87 golden with BOTH frozen binaries.
# usage: vcase.sh <case dir>   env: ELAB=1 for the -elabuhdm form; EXTRA_ENV="VAR=1 ..." applied to the LAW binary only
# prints: <case> <form> pris=<verdict> law=<verdict> bytes=<same|moved>; artefacts under /tmp/v11u210_run/<md5>/{P,L}
# Fail closed on the fence (the FENCED= line of r11u107repro/canaudit.sh in the main repository).
set -u
D=$(cd "$1" && pwd)
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO="$(cd "$(git -C "$HERE" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || echo /home/heyfey/git-repos/slang-uhdm/.git)/.." && pwd)"
FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "vcase: fence unreadable" >&2; exit 3; }
for f in $FENCED; do grep -qw -- "$f" <<< "$D" && { echo "vcase: fenced path refused" >&2; exit 3; }; done
SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
BIN=/tmp/v11u210_bin; SCMP=$BIN/uhdm-strictcmp
PB=${PRIS_BIN:-$BIN/pris.bin}; LB=${LAW_BIN:-$BIN/law.bin}
SLE=; OUE=; FORM=parse; [ -n "${ELAB:-}" ] && { SLE=-elabuhdm; OUE=--elabuhdm; FORM=elab; }
SRC=dut.sv; [ -f "$D/args" ] && SRC=$(cat "$D/args")
K=$(cd "$D" && find . -type f ! -name LAW | sort | xargs md5sum | md5sum | cut -c1-16)
G=/tmp/v11u210_gold/$K$FORM; O=/tmp/v11u210_run/$(echo "$D$FORM${TAG:-}" | md5sum | cut -c1-12)
mkdir -p "$O"
if [ ! -s "$G/golden.uhdm" ]; then mkdir -p "$G/w"; ( cd "$D" && "$SURELOG" -parse $SLE -nobuiltin -nocache -sv $SRC -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"; fi
[ -s "$G/golden.uhdm" ] || { echo "$1 $FORM SURELOG_FAIL"; exit 1; }
"$UHDM_DUMP" "$G/golden.uhdm" 2>/dev/null > "$O/g.dump"
verdict() { # $1 tag $2 bin $3 envs
  local o=$O/$1; mkdir -p $o; rm -f $o/ours.uhdm
  ( cd "$D" && env $3 "$2" $SRC --single-unit --nobuiltin $OUE -o "$o/ours.uhdm" > "$o/slang.log" 2>&1; echo "rc=$?" >> "$o/slang.log" )
  [ -s "$o/ours.uhdm" ] || { echo "SLANG_FAIL($(tail -1 $o/slang.log))"; return; }
  "$UHDM_CMP" "$G/golden.uhdm" "$o/ours.uhdm" > "$o/cmp.txt" 2>&1; local c=$?
  "$SCMP" --max 50 --dump-a "$o/a.rec" --dump-b "$o/b.rec" "$G/golden.uhdm" "$o/ours.uhdm" > "$o/strict.txt" 2>&1
  "$UHDM_DUMP" "$o/ours.uhdm" 2>/dev/null > "$o/o.dump"
  local v; v=$("$SCMP" --max 0 "$G/golden.uhdm" "$o/ours.uhdm" 2>&1 | awk '/^STRICT_EQUAL/{print "equal"; exit} /^STRICT_NOTEQUAL/{f=$2} /objects_differing=/{split($0,a,"objects_differing="); split(a[2],b," "); n=b[1]} END{if(f!="") print f"("n")"}')
  [ $c -ne 0 ] && v=stage1
  echo "cmp$c:$(tail -1 $o/slang.log):${v:-?}"
}
p=$(verdict P "$PB" "${PRIS_ENV:-}"); l=$(verdict L "$LB" "${EXTRA_ENV:-}")
b=same; cmp -s "$O/P/ours.uhdm" "$O/L/ours.uhdm" || b=moved
echo "$(realpath --relative-to=$REPO $D 2>/dev/null || echo $D) $FORM pris=$p law=$l bytes=$b out=$O"
