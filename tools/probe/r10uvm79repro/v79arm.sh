#!/usr/bin/env bash
# r10uvm79repro/v79arm.sh — THE VERIFIER'S ARM RUNNER.
#
#   GOLD=<surelog> PRI=<pristine build> PAT=<patched build> v79arm.sh <arm.sv>
#
# WHY IT IS NOT ct79arm.sh: ct79arm.sh reports a WHOLE-FILE dump distance, and a
# whole-file number cannot answer the only question a verifier has — "is there a
# CELL where the PRISTINE build matched golden and the PATCHED one does not?".
# A patch that fixes 200 lines and breaks 2 still prints a smaller total.
# `v79perline.py` therefore buckets every dump line by the SOURCE LINE it
# carries and prints d(golden,pristine) and d(golden,patched) PER BUCKET, so a
# per-cell regression is a printed word (`**WORSE**`) and not an inference from
# an aggregate.
#
# GUARDS:
#   * golden, pristine and patched are produced in the SAME scratch dir, so the
#     absolute paths uhdm-dump prints for Surelog's synthesized builtin.sv are
#     identical in all three reads (r10uvm77 §3).
#   * a missing output prints NO_OUTPUT and is COUNTED — a driver that reached
#     nothing must never read as perfection.
#   * SURELOG_FAIL is fatal for the arm: an arm whose GOLDEN does not exist
#     cannot answer anything, and must not read as "no regression".
set -u
SRC=${1:?arm source}
PRI=${PRI:?set PRI to the PRISTINE build}
PAT=${PAT:?set PAT to the PATCHED build}
SURELOG=${GOLD:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
HERE=$(cd "$(dirname "$0")" && pwd)
B=$(basename "$SRC"); B=${B%.*}
D=/tmp/v79arm_$B
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$LEAF" > surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; tail -6 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null > g.dump
for tag in pris pat; do
  bin=$PRI; [ "$tag" = pat ] && bin=$PAT
  "$bin" "$LEAF" -o $tag.uhdm > $tag.log 2>&1
  [ -f $tag.uhdm ] || { echo "NO_OUTPUT $B/$tag"; tail -4 $tag.log; exit 6; }
  "$DUMP" $tag.uhdm 2>/dev/null > $tag.dump
done
echo "== $B   (LHS/golden = Surelog; d = dump-line multiset distance to golden)"
python3 "$HERE/v79perline.py" g.dump pris.dump pat.dump
echo "WD=$D"
