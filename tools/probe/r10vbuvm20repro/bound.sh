#!/usr/bin/env bash
# vbuvm20 BOUNDARY GATE -- recursive over a COPY of tools/probe, N binaries,
# BOTH views (default and --elabuhdm), fd-3 arm list, children </dev/null,
# PROCESSED asserted against LISTED, rc recorded per cell, per-file AND
# per-directory (subdirectory arms included by construction: `find`).
set -u
: "${ROOT:?probe root}"; : "${OUT:?out}"; : "${BINS:?space separated name=path}"
rm -rf "$OUT"; mkdir -p "$OUT"
LIST=$OUT/arms.txt
( cd "$ROOT" && find . -name '*.sv' -type f | LC_ALL=C sort ) > "$LIST"
N=$(wc -l < "$LIST")
echo "== boundary: $N arms under $ROOT, bins: $BINS"
: > "$OUT/differ.txt"; : > "$OUT/asym.txt"; : > "$OUT/rc.txt"
proc=0
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  proc=$((proc+1))
  key=$(printf '%s' "$rel" | sed 's#^\./##; s#/#__#g; s#\.sv$##')
  d="$OUT/w/$key"; mkdir -p "$d"; cp "$ROOT/$rel" "$d/a.sv"
  for view in d e; do
    [ "$view" = d ] && FL="" || FL="--elabuhdm"
    first=""; base=""
    for spec in $BINS; do
      nm=${spec%%=*}; bp=${spec#*=}
      ( cd "$d" && "$bp" a.sv $FL -o $nm.$view.uhdm >$nm.$view.log 2>&1; echo "rc=$?" >>$nm.$view.log ) </dev/null
      echo "$rel $view $nm rc=$(sed -n 's/^rc=//p' "$d/$nm.$view.log" | tail -1) db=$([ -s "$d/$nm.$view.uhdm" ] && echo 1 || echo 0)" >> "$OUT/rc.txt"
      if [ -s "$d/$nm.$view.uhdm" ]; then
        ( cd "$d" && uhdm-dump $nm.$view.uhdm 2>&1 | sed '1s#^[^:]*\.uhdm:#<DB>:#' > $nm.$view.txt ) </dev/null
      else
        : > "$d/$nm.$view.txt"
      fi
      if [ -z "$first" ]; then first=$nm; base="$d/$nm.$view.txt"; bdb=$([ -s "$d/$nm.$view.uhdm" ] && echo 1 || echo 0)
      else
        odb=$([ -s "$d/$nm.$view.uhdm" ] && echo 1 || echo 0)
        [ "$odb" != "$bdb" ] && echo "ASYM $rel $view $first=$bdb $nm=$odb" >> "$OUT/asym.txt"
        cmp -s "$base" "$d/$nm.$view.txt" || echo "$rel $view $first-vs-$nm" >> "$OUT/differ.txt"
      fi
    done
  done
  rm -f "$d"/*.uhdm
  if ! grep -q "^$rel " "$OUT/differ.txt" 2>/dev/null; then rm -rf "$d"; fi
done
exec 3<&-
echo "PROCESSED=$proc LISTED=$N"
[ "$proc" = "$N" ] || { echo "FATAL: PROCESSED != LISTED"; exit 9; }
echo "DIFFER_CELLS=$(grep -c '' "$OUT/differ.txt"; true)  ASYM=$(grep -c '' "$OUT/asym.txt"; true)"
sort -u "$OUT/differ.txt"
