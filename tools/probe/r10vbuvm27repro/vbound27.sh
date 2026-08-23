#!/usr/bin/env bash
# r10vbuvm27 WIDE BOUNDARY — every .sv/.v under a COPY of tools/probe, BOTH
# views, both binaries, PARALLEL but with the same discipline as bound27.sh:
#   * NO path filter, .sv AND .v, recursive (subdirectory arms included)
#   * the file list is read on fd 3; every child runs with </dev/null
#   * PROCESSED is asserted equal to LISTED (minus counted FENCE skips)
#   * rc of EVERY invocation is recorded per cell
#   * scratch keyed on the RELATIVE path (three different `dut.sv` exist)
# usage: PRI=… PAT=… ROOT=<copy of tools/probe> [BWD=…] [JOBS=…] ./vbound27.sh
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
WD=${BWD:-/tmp/vbuvm27_bound}; JOBS=${JOBS:-8}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/sources.txt
find "$ROOT" \( -name '*.sv' -o -name '*.v' \) | LC_ALL=C sort > "$LIST"
listed=$(wc -l < "$LIST"); [ "$listed" -gt 0 ] || { echo EMPTY-LIST; exit 4; }
cat > "$WD/cell.sh" <<'CELL'
#!/usr/bin/env bash
set -u
src=$1; n=$2
ROOT=$ROOT_E; WD=$WD_E; PRI=$PRI_E; PAT=$PAT_E; DUMP=$DUMP_E
rel=${src#$ROOT/}
b=$(printf "%05d_%s" "$n" "$(printf '%s' "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')")
o=$WD/$b; mkdir -p "$o" || exit 0
leaf=$(basename "$src"); cp "$src" "$o/" || exit 0
echo "$rel" > "$o/REL"
for m in def elab; do
  fl=""; [ $m = elab ] && fl="-elabuhdm"
  ( cd "$o" && "$PRI" $fl "$leaf" -o pris_$m.uhdm >pris_$m.log 2>&1 </dev/null; echo $? > rc_pris_$m )
  ( cd "$o" && "$PAT" $fl "$leaf" -o pat_$m.uhdm  >pat_$m.log  2>&1 </dev/null; echo $? > rc_pat_$m )
  if [ ! -f "$o/pris_$m.uhdm" ] || [ ! -f "$o/pat_$m.uhdm" ]; then
    if [ -f "$o/pris_$m.uhdm" ] || [ -f "$o/pat_$m.uhdm" ]; then
      echo "ASYMMETRIC_OUTPUT $rel/$m rc_pris=$(cat "$o/rc_pris_$m") rc_pat=$(cat "$o/rc_pat_$m")" >> "$WD/moved.txt"
    else
      echo "$rel/$m" >> "$WD/noout.txt"
    fi
    continue
  fi
  "$DUMP" "$o/pris_$m.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris_$m.dump"
  "$DUMP" "$o/pat_$m.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat_$m.dump"
  if ! cmp -s "$o/pris_$m.dump" "$o/pat_$m.dump"; then
    nl=$(diff "$o/pris_$m.dump" "$o/pat_$m.dump" | grep -cE '^[<>]'; true)
    ob=$( { sort "$o/pris_$m.dump" > "$o/p.s"; sort "$o/pat_$m.dump" > "$o/q.s"; diff "$o/p.s" "$o/q.s" | grep -cE '^[<>]'; true; } )
    echo "MOVED $rel/$m raw=$nl orderblind=$ob rc_pris=$(cat "$o/rc_pris_$m") rc_pat=$(cat "$o/rc_pat_$m")" >> "$WD/moved.txt"
  fi
done
echo "$rel" >> "$WD/processed.txt"
CELL
chmod +x "$WD/cell.sh"
export ROOT_E="$ROOT" WD_E="$WD" PRI_E="$PRI" PAT_E="$PAT" DUMP_E="$DUMP"
: > "$WD/processed.txt"; : > "$WD/moved.txt"; : > "$WD/noout.txt"
fenced=0
n=0
: > "$WD/work.tsv"
exec 3< "$LIST"
while IFS= read -r src <&3; do
  n=$((n+1))
  if [ -n "${FENCE_RE:-}" ] && printf '%s' "$(basename "$src")" | grep -qE "$FENCE_RE"; then
    fenced=$((fenced+1)); continue
  fi
  printf '%s\t%d\n' "$src" "$n" >> "$WD/work.tsv"
done
exec 3<&-
# children each get </dev/null; the LIST is never on their stdin
xargs -P "$JOBS" -a "$WD/work.tsv" -d '\n' -I{} \
  bash -c 'line="{}"; s="${line%%$'"'"'\t'"'"'*}"; i="${line##*$'"'"'\t'"'"'}"; "$WD_E/cell.sh" "$s" "$i" </dev/null' </dev/null
proc=$(wc -l < "$WD/processed.txt")
moved=$(grep -c . "$WD/moved.txt"; true)
noout=$(grep -c . "$WD/noout.txt"; true)
sort "$WD/moved.txt"
echo "LISTED=$listed FENCED_SKIPPED=$fenced PROCESSED=$proc MOVED=$moved NO_OUTPUT_PAIRS=$noout"
[ $((proc+fenced)) -eq "$listed" ] || { echo "PROCESSED-ASSERT-FAILED"; exit 6; }
echo "PROCESSED-ASSERT-OK"
