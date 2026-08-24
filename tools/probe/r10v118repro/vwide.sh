#!/usr/bin/env bash
# r10v118 VERIFIER's OWN wide boundary.  PER-FILE and PER-DIRECTORY arms over a
# COPY of tools/probe, NO path filter, .sv and .v at ANY depth, BOTH views,
# BOTH frozen binaries.  List on fd 3, children </dev/null, rc per cell,
# PROCESSED asserted, scratch keyed on the RELATIVE path.
set -u
PAT=/tmp/v118_bin/slang-uhdm-patched
PRIS=/tmp/v118_bin/slang-uhdm-pristine
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=${PROBE_ROOT:?}; STAGE=${STAGE:?}; LIST=$1; OUT=$2; MODE=${3:-file}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$STAGE"; : > $OUT.diff; : > $OUT.signal; : > $OUT.rc
n=0; same=0; diffn=0; noout=0
while read -r f <&3; do
  n=$((n+1))
  rel=${f#$ROOT/}
  key=$(printf '%s' "$rel" | tr '/ ' '__')
  for view in plain elab; do
    case $view in plain) FLAGS="";; elab) FLAGS="--elabuhdm";; esac
    ok=1
    for side in A B; do
      case $side in A) BIN=$PAT;; B) BIN=$PRIS;; esac
      d="$STAGE/${key}__${view}__$side"; mkdir -p "$d" || { ok=0; continue; }
      if [ "$MODE" = dir ]; then
        srcs=""
        for s in "$f"/*.sv "$f"/*.v; do [ -f "$s" ] && { cp "$s" "$d/" 2>/dev/null; srcs="$srcs $(basename "$s")"; }; done
        [ -n "$srcs" ] || { ok=0; continue; }
        ( cd "$d" && "$BIN" $FLAGS $srcs -o slang.uhdm >slang.log 2>&1 </dev/null ); rc=$?
      else
        cp "$f" "$d/" 2>/dev/null || { ok=0; continue; }
        ( cd "$d" && "$BIN" $FLAGS "$(basename "$f")" -o slang.uhdm >slang.log 2>&1 </dev/null ); rc=$?
      fi
      echo "$rc $side $view $rel" >> $OUT.rc
      [ "$rc" -gt 128 ] && echo "SIGNAL rc=$rc $side $view $rel" >> $OUT.signal
      [ -f "$d/slang.uhdm" ] || { ok=0; continue; }
      "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' | sed "s#${key}__${view}__$side#WD#g; s#$STAGE#STG#g" > "$d/o.norm"
      [ -s "$d/o.norm" ] || ok=0
    done
    if [ "$ok" = 0 ]; then noout=$((noout+1)); rm -rf "$STAGE/${key}__${view}__A" "$STAGE/${key}__${view}__B"; continue; fi
    if cmp -s "$STAGE/${key}__${view}__A/o.norm" "$STAGE/${key}__${view}__B/o.norm"; then
      same=$((same+1)); rm -rf "$STAGE/${key}__${view}__A" "$STAGE/${key}__${view}__B"
    else
      diffn=$((diffn+1)); echo "$view $rel" >> $OUT.diff
    fi
  done
done 3< "$LIST"
echo "MODE=$MODE PROCESSED=$n LISTED=$(grep -c . "$LIST") identical=$same DIFFERING=$diffn no_output=$noout" > $OUT.tally
awk '{c[$1]++} END {for (k in c) printf "rc=%s %d\n", k, c[k]}' $OUT.rc | sort > $OUT.rc_histogram
cat $OUT.tally
