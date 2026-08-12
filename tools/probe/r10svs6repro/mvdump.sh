#!/bin/bash
# r10svs6repro/mvdump.sh — dump a MOVER's three databases (golden, pristine-ours,
# patched-ours) into one directory, ready for msmovers.sh / shape counting.
#
#   usage: mvdump.sh <rel-path-under-workdir> <patched_wd_root> <pristine_wd_root> <outdir>
#     e.g. mvdump.sh ./default/SVSwitch-db796243 /tmp/.../wd_sl_patch /tmp/.../wd_sl_pris /tmp/mv/SVSwitch_default
#
# GUARDS:
#   * uhdm-dump's FIRST LINE is the database path and always differs -> `sed 1d`
#     on all three, so every later count is real content.
#   * the GOLDEN is located the way svsgen.sh locates it: the local slpp_all /
#     slpp_unit copy, else the `golden cache hit` line in cmds.txt.  A golden that
#     cannot be found is exit 6, never an empty dump (which would make every
#     shape count read "golden=0" and invert the verdict).
#   * every produced dump is non-empty-checked.
set -u
REL=${1:?rel path}
A=${2:?patched wd}
B=${3:?pristine wd}
OUT=${4:?outdir}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump"; exit 3; }
mkdir -p "$OUT" || exit 1
PA=$A/$REL/slang.uhdm; PB=$B/$REL/slang.uhdm
[ -f "$PA" ] && [ -f "$PB" ] || { echo "FATAL: missing ours db"; exit 6; }
W=$A/$REL
G=$(ls "$W"/slpp_all/*.uhdm "$W"/slpp_unit/*.uhdm 2>/dev/null | head -1)
if [ -z "${G:-}" ]; then
    C=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' "$W/cmds.txt")
    G=$(ls "$C"/*.uhdm 2>/dev/null | head -1)
fi
[ -n "${G:-}" ] && [ -f "$G" ] || { echo "FATAL: golden not found for $REL"; exit 6; }
"$DUMP" "$G"  | sed '1d' > "$OUT/g.dump"
"$DUMP" "$PB" | sed '1d' > "$OUT/p.dump"
"$DUMP" "$PA" | sed '1d' > "$OUT/a.dump"
for f in g p a; do [ -s "$OUT/$f.dump" ] || { echo "FATAL: empty $f.dump"; exit 6; }; done
echo "$REL  golden=$G"
echo "  lines: g=$(wc -l < "$OUT/g.dump") p=$(wc -l < "$OUT/p.dump") a=$(wc -l < "$OUT/a.dump")"
