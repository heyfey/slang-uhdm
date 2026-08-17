#!/usr/bin/env bash
# r10rgg3/boundary.sh — the BOUNDARY gate: every COMMITTED probe arm in
# tools/probe/*repro/ re-run under BOTH binaries and BYTE-compared.
#
#   usage: BASE=<bin> PAT=<bin> ./boundary.sh [<probe-dir> ...]
#          (no args: every tools/probe/*repro directory except this pass's own)
#
# An arm is a directory holding `dut.sv` (with `top.sv` beside it if present) or
# a bare `*.sv` file directly inside a probe dir.  Each is exported to a temp
# database twice and md5'd.
#
# GUARDS: an arm on which EITHER binary produced no database is reported
# NO-DATABASE and COUNTED (an arm that produced nothing must never read as
# byte-identical); the arm count is printed and a run with zero arms exits 4.
set -u
BASE=${BASE:?BASE=<base binary>}
PAT=${PAT:?PAT=<patched binary>}
here=$(cd "$(dirname "$0")" && pwd)
probe=$(cd "$here/.." && pwd)
mine=$(basename "$here")
dirs=("$@")
if [ ${#dirs[@]} -eq 0 ]; then
  mapfile -t dirs < <(cd "$probe" && ls -d *repro 2>/dev/null | grep -v "^$mine\$")
fi
W=$(mktemp -d); arms=0; moved=0; nodb=0
run() { # $1=binary $2=out $3.. = sources
  local b=$1 o=$2; shift 2
  ( cd "$(dirname "$1")" && "$b" --single-unit $(for f in "$@"; do basename "$f"; done) -o "$o" ) \
      > /dev/null 2>&1
}
check() { # $@ = sources of one arm
  local id
  id=$(printf '%s\n' "$1" | sed "s#$probe/##; s#/#_#g")
  run "$BASE" "$W/b.uhdm" "$@"
  run "$PAT"  "$W/p.uhdm" "$@"
  arms=$((arms+1))
  if [ ! -s "$W/b.uhdm" ] || [ ! -s "$W/p.uhdm" ]; then
    echo "  NO-DATABASE $id"; nodb=$((nodb+1)); rm -f "$W/b.uhdm" "$W/p.uhdm"; return
  fi
  if ! cmp -s "$W/b.uhdm" "$W/p.uhdm"; then
    echo "  MOVED       $id  base=$(md5sum "$W/b.uhdm"|cut -c1-12) pat=$(md5sum "$W/p.uhdm"|cut -c1-12)"
    moved=$((moved+1))
  fi
  rm -f "$W/b.uhdm" "$W/p.uhdm"
}
for d in "${dirs[@]}"; do
  [ -d "$probe/$d" ] || continue
  while IFS= read -r f; do
    dd=$(dirname "$f")
    if [ -f "$dd/top.sv" ]; then check "$f" "$dd/top.sv"; else check "$f"; fi
  done < <(find "$probe/$d" -name dut.sv | sort)
  while IFS= read -r f; do
    check "$f"
  done < <(find "$probe/$d" -maxdepth 1 -name '*.sv' ! -name top.sv | sort)
done
rm -rf "$W"
echo "ARMS=$arms MOVED=$moved NO-DATABASE=$nodb"
[ "$arms" -gt 0 ] || { echo "REFUSING TO REPORT: zero arms"; exit 4; }
[ "$moved" -eq 0 ]
