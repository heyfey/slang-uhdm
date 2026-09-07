#!/usr/bin/env bash
# r10earl120 -- MOVER ATTRIBUTION: the SECTIONED, path-normalised, ORDER-BLIND
# whole-dump diff of one database, pristine vs patched.
#
# MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
#
#   usage: attrib120.sh <pristine.uhdm> <patched.uhdm> <outdir>
#
# TRAPS ENCODED (RESUME.md section 8/9):
#   * dump paths EMBED the workdir, so both dumps are path-normalised before
#     anything is compared -- a raw diff of two workdirs is all noise;
#   * the diff is taken BOTH raw (order-sensitive) and ORDER-BLIND (sorted), so
#     a pure ordering flip -- the documented parallel-parse coin -- shows as
#     zero order-blind lines and is not attributed to the law;
#   * the dump is SECTIONED at `|uhdmtopModules:` into DEF / ELAB / the
#     weaklyReferenced TAIL, and the TAIL IS NEVER COUNTED: it is unreachable
#     to the judge (earl60's brief-refutation).
set -u
P=${1:?pristine.uhdm}; A=${2:?patched.uhdm}; O=${3:?outdir}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$DUMP" ] || DUMP=$HOME/.local/bin/uhdm-dump
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump"; exit 3; }
mkdir -p "$O"
norm() { sed -E 's#/tmp/[A-Za-z0-9_.-]+/#/WD/#g; s#[0-9a-f]{8,}#HASH#g'; }
"$DUMP" "$P" 2>/dev/null | norm > "$O/pris.dump"
"$DUMP" "$A" 2>/dev/null | norm > "$O/patch.dump"
for s in pris patch; do
  awk 'BEGIN{n=0} /\|uhdmtopModules:/{n++} {print n "\t" $0}' "$O/$s.dump" > "$O/$s.sec"
done
echo "== RAW (order-sensitive) whole-dump diff"
diff "$O/pris.dump" "$O/patch.dump" > "$O/raw.diff"; echo "  lines: $(wc -l < "$O/raw.diff")"
echo "== ORDER-BLIND (sorted) whole-dump diff"
sort "$O/pris.dump" > "$O/pris.sorted"; sort "$O/patch.dump" > "$O/patch.sorted"
diff "$O/pris.sorted" "$O/patch.sorted" > "$O/sorted.diff"
echo "  lines: $(wc -l < "$O/sorted.diff")"
echo "== ORDER-BLIND diff BY SECTION (0 = before the first uhdmtopModules = DEF,"
echo "   1..n = ELAB, the LAST section is the weaklyReferenced TAIL, NOT COUNTED)"
for s in pris patch; do sort "$O/$s.sec" > "$O/$s.sec.sorted"; done
diff "$O/pris.sec.sorted" "$O/patch.sec.sorted" > "$O/sec.diff"
awk -F'\t' '/^[<>]/{split($0,a," "); print substr($0,1,1) " sec=" a[2]}' "$O/sec.diff" |
  sed 's/sec=\([0-9]*\).*/sec=\1/' | sort | uniq -c
echo "== CHANGED LINE SHAPES (order-blind, added side)"
grep '^>' "$O/sorted.diff" | sed -E 's/^> *//; s/id:[0-9]+/id:N/g; s/[0-9]+/N/g' |
  sort | uniq -c | sort -rn | head -20
echo "== CHANGED LINE SHAPES (order-blind, removed side)"
grep '^<' "$O/sorted.diff" | sed -E 's/^< *//; s/id:[0-9]+/id:N/g; s/[0-9]+/N/g' |
  sort | uniq -c | sort -rn | head -20
