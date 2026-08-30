#!/usr/bin/env bash
# r10uvm166 - THE FAMILY CENSUS over named rows of TWO verify_golden workdirs
# (pristine and patched), scored three ways against the SAME golden.
# MEASUREMENT ONLY; the official uhdm-cmp is the sole judge.
# LHS/G is ALWAYS golden (Surelog).
#
#   usage: CEN=<ct166cen> SCORE=<score166.py> census166.sh \
#              <pristine workdir> <patched workdir> <outdir> <name> [<name>...]
#
# GUARDS: the golden path is read out of the row's OWN cmds.txt (so the census
# cannot silently compare against another row's golden); a row missing either
# side prints SKIP-NOFILE and is COUNTED; scratch is keyed on the row's
# RELATIVE path, because the two modes share a name.
set -u
CEN=${CEN:?ct166cen}; SCORE=${SCORE:?score166.py}
A=${1:?pristine workdir}; B=${2:?patched workdir}; OUT=${3:?outdir}; shift 3
mkdir -p "$OUT"; miss=0; n=0
for nm in "$@"; do
  for mode in default testflags; do
    for d in "$A/$mode/$nm"-*/; do
      [ -d "$d" ] || continue
      rel=${d#"$A"/}; key=$(echo "${rel%/}" | tr '/' '_')
      G=""
      [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      P="$B/${rel}slang.uhdm"
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$d/slang.uhdm" ] || [ ! -f "$P" ]; then
        echo "SKIP-NOFILE $rel"; miss=$((miss+1)); continue
      fi
      "$CEN" "$G"            G.corpus > "$OUT/$key.g.tsv" 2>/dev/null
      "$CEN" "$d/slang.uhdm" O.corpus > "$OUT/$key.a.tsv" 2>/dev/null
      "$CEN" "$P"            O.corpus > "$OUT/$key.b.tsv" 2>/dev/null
      python3 "$SCORE" "$OUT/$key.g.tsv" "$OUT/$key.a.tsv" "$OUT/$key.b.tsv" \
        > "$OUT/$key.score.txt" 2>&1
      printf '%-34s %s\n' "$key" "$(tail -1 "$OUT/$key.score.txt")"
      n=$((n+1))
    done
  done
done
echo "-- rows=$n SKIP-NOFILE=$miss"
