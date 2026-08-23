#!/usr/bin/env bash
# r10vbuvm29 WIDE boundary gate (VERIFIER).  Same discipline as bound29.sh --
# a COPY of tools/probe, NO path filter, `.sv` AND `.v`, subdirectories
# included, the file list read on fd 3, every child `</dev/null`, rc recorded
# per cell, PROCESSED asserted against LISTED -- but SHARDED so the 3388-file
# x 2-view x 2-binary sweep finishes in bounded time.  Each shard keeps the
# fd-3 discipline on its own slice; the aggregate asserts the total.
#   usage: PRI=.. PAT=.. ROOT=<copy of tools/probe> BWD=.. SHARDS=4 ./vbound29.sh
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
WD=${BWD:-/tmp/vbuvm29_bound}
SHARDS=${SHARDS:-4}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/sources.txt
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) | sort > "$LIST"
listed=$(wc -l < "$LIST")
[ "$listed" -gt 0 ] || { echo "EMPTY-LIST"; exit 4; }
echo "LISTED=$listed SHARDS=$SHARDS"
split -n l/$SHARDS -d "$LIST" "$WD/shard_"
shard_run() {
  local sf=$1 idx=$2
  local proc=0 n=0
  exec 3< "$sf"
  while IFS= read -r src <&3; do
    n=$((n+1))
    rel=${src#$ROOT/}
    b=$(printf "s%s_%04d_%s" "$idx" "$n" "$(echo "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')")
    o=$WD/$b; mkdir -p "$o"; cp "$src" "$o/" || continue
    leaf=$(basename "$src")
    proc=$((proc+1))
    for m in def elab; do
      fl=""; [ $m = elab ] && fl="-elabuhdm"
      ( cd "$o" && "$PRI" $fl "$leaf" -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null; echo "rc_pris_$m=$?" >> rc.txt )
      ( cd "$o" && "$PAT" $fl "$leaf" -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null; echo "rc_pat_$m=$?"  >> rc.txt )
      if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
        if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then
          echo "ASYMMETRIC_OUTPUT $rel/$m" >> "$WD/moved.txt"
        else
          echo "$rel/$m" >> "$WD/noout.txt"
        fi
        continue
      fi
      "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris_$m.dump"
      "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat_$m.dump"
      if ! cmp -s "$o/pris_$m.dump" "$o/pat_$m.dump"; then
        echo "MOVED $rel/$m $(diff "$o/pris_$m.dump" "$o/pat_$m.dump" | grep -cE '^[<>]'; true) lines [$b]" >> "$WD/moved.txt"
      else
        rm -f "$o"/*.dump "$o"/*.uhdm
      fi
    done
  done
  exec 3<&-
  echo "$proc" > "$WD/proc_$idx.txt"
}
i=0
for sf in "$WD"/shard_*; do
  shard_run "$sf" "$i" &
  i=$((i+1))
done
wait
proc=$(cat "$WD"/proc_*.txt | awk '{s+=$1} END{print s+0}')
moved=$(grep -c . "$WD/moved.txt" 2>/dev/null; true)
noout=$(grep -c . "$WD/noout.txt" 2>/dev/null; true)
echo "LISTED=$listed PROCESSED=$proc MOVED=$moved NO_OUTPUT_PAIRS=$noout"
[ "$proc" -eq "$listed" ] || { echo "PROCESSED-ASSERT-FAILED"; exit 6; }
echo "PROCESSED-ASSERT-OK"
