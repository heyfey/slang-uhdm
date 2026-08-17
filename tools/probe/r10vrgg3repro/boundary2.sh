#!/usr/bin/env bash
# r10vrgg3/boundary2.sh — the boundary gate, WITH THE HOLE IN r10rgg3's
# boundary.sh CLOSED.
#
# THE HOLE: r10rgg3repro/boundary.sh reports NO-DATABASE whenever EITHER binary
# produced no database, counts it in `nodb`, and then exits on `moved -eq 0`.
# An arm where the BASE produced a database and the PATCH did not (or the
# reverse) is therefore reported as NO-DATABASE and the script still exits 0 —
# exactly the pristine-right -> patched-wrong shape the gate exists to catch.
# Here the two sides are counted SEPARATELY and any ASYMMETRY is fatal.
set -u
BASE=${BASE:?}; PAT=${PAT:?}
probe=${PROBE:-$(cd "$(dirname "$0")/.." && pwd)}
mine=${MINE:-$(basename "$(cd "$(dirname "$0")" && pwd)")}
dirs=("$@")
if [ ${#dirs[@]} -eq 0 ]; then
  mapfile -t dirs < <(cd "$probe" && ls -d *repro 2>/dev/null | grep -v "^$mine\$")
fi
W=$(mktemp -d); arms=0; moved=0; both_none=0; asym=0
run() { local b=$1 o=$2; shift 2
  ( cd "$(dirname "$1")" && "$b" --single-unit $(for f in "$@"; do basename "$f"; done) -o "$o" ) >/dev/null 2>&1; }
check() {
  local id; id=$(printf '%s\n' "$1" | sed "s#$probe/##; s#/#_#g")
  rm -f "$W/b.uhdm" "$W/p.uhdm"
  run "$BASE" "$W/b.uhdm" "$@"; local rb=$?
  run "$PAT"  "$W/p.uhdm" "$@"; local rp=$?
  arms=$((arms+1))
  local hb=0 hp=0
  [ -s "$W/b.uhdm" ] && hb=1; [ -s "$W/p.uhdm" ] && hp=1
  if [ $hb -ne $hp ]; then
    echo "  ASYMMETRIC-DATABASE $id  base_db=$hb(rc=$rb) pat_db=$hp(rc=$rp)"
    asym=$((asym+1)); return
  fi
  if [ $hb -eq 0 ]; then
    echo "  NO-DATABASE-BOTH   $id  (base rc=$rb pat rc=$rp)"
    both_none=$((both_none+1)); return
  fi
  if ! cmp -s "$W/b.uhdm" "$W/p.uhdm"; then
    echo "  MOVED  $id base=$(md5sum "$W/b.uhdm"|cut -c1-12) pat=$(md5sum "$W/p.uhdm"|cut -c1-12)"
    moved=$((moved+1))
  fi
}
for d in "${dirs[@]}"; do
  [ -d "$probe/$d" ] || continue
  while IFS= read -r f; do
    dd=$(dirname "$f")
    if [ -f "$dd/top.sv" ]; then check "$f" "$dd/top.sv"; else check "$f"; fi
  done < <(find "$probe/$d" -name dut.sv | sort)
  while IFS= read -r f; do check "$f"; done \
    < <(find "$probe/$d" -maxdepth 1 -name '*.sv' ! -name top.sv | sort)
done
rm -rf "$W"
echo "ARMS=$arms MOVED=$moved NO-DATABASE-BOTH=$both_none ASYMMETRIC=$asym"
[ "$arms" -gt 0 ] || { echo "REFUSING TO REPORT: zero arms"; exit 4; }
[ "$moved" -eq 0 ] && [ "$asym" -eq 0 ]
