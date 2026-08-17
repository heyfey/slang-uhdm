#!/usr/bin/env bash
# r10uvm86 — THE BOUNDARY RUNNER.  MEASUREMENT-ONLY.
# Compiles every named arm source of the NEIGHBOURING passes with BOTH binaries
# and reports byte-identity of the DUMPS.  A boundary arm that moves is a cell
# this law was not allowed to touch; a source neither binary can compile prints
# NO_OUTPUT and is COUNTED, so an unreadable arm can never read as green.
#   usage: v86bound.sh <dir> [<dir> ...]
set -u
PAT=${PAT:?patched binary}
PRI=${PRI:?pristine binary}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
same=0; moved=0; noout=0; n=0
for d in "$@"; do
  for f in "$d"/*.sv; do
    [ -f "$f" ] || continue
    n=$((n+1))
    b=$(basename "$f"); b=${b%.sv}
    W=/tmp/r10uvm86_bound/$(basename "$d")_$b
    rm -rf "$W"; mkdir -p "$W"; cp "$f" "$W/" || continue
    ok=1
    for tag in pris pat; do
      bin=$PRI; [ $tag = pat ] && bin=$PAT
      ( cd "$W" && "$bin" "$b.sv" -o $tag.uhdm > $tag.log 2>&1 )
      [ -f "$W/$tag.uhdm" ] || ok=0
      [ -f "$W/$tag.uhdm" ] && "$DUMP" "$W/$tag.uhdm" 2>/dev/null | sed 1d > "$W/$tag.dump"
    done
    if [ $ok = 0 ]; then echo "NO_OUTPUT   $(basename $d)/$b"; noout=$((noout+1)); continue; fi
    if cmp -s "$W/pris.dump" "$W/pat.dump"; then same=$((same+1))
    else moved=$((moved+1)); echo "MOVED       $(basename $d)/$b  $(diff "$W/pris.dump" "$W/pat.dump" | grep -cE '^[<>]') dump lines"; fi
  done
done
echo "boundary arms: sources=$n  BYTE-IDENTICAL=$same  MOVED=$moved  NO_OUTPUT=$noout"
