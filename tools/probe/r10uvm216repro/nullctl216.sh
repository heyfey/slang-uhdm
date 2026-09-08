#!/usr/bin/env bash
# r10uvm216 — THE LAYOUT-NULL CONTROL.  MEASUREMENT ONLY.
#
# Three surelog rows moved bytes that the law's a-priori prediction did NOT
# name (BuildUVMPkg x2, SeqDriver/default), and seven committed boundary arms
# that carry NO `export "DPI-C"` item at all moved too.  None of them can have
# been touched by § dpiExportListedAtExportItem216 — but "it cannot have been
# touched" is an argument, not a measurement.
#
# This script measures it.  `$NULL` is a binary built from a CLEAN b7eb7ff3
# worktree carrying TWO UNUSED members of exactly the shape this pass's law
# adds to `UhdmExporter` — so its object layout and heap traffic change and its
# BEHAVIOUR cannot.  Any database that moves between `$PRIS` and `$NULL` is
# moving for LAYOUT.  The null binary is never committed and is no part of the
# patch.
#
# It replays each row's OWN `cmds.txt` slang command line IN THAT ROW'S OWN
# WORKDIR (relative source paths), rewriting only the
# -o output path) with all three binaries and reports the three md5s.
#
# usage: PRIS=.. PATCHED=.. NULL=.. ./nullctl216.sh <sweep-workdir> <scratch> <out> <mode/row> ...
set -u
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}; NULL=${NULL:?}
WD=${1:?sweep workdir}; SCR=${2:?scratch}; OUT=${3:?out}; shift 3
mkdir -p "$SCR" || exit 1
: > "$OUT"
for r in "$@"; do
  d=$WD/$r
  [ -f "$d/cmds.txt" ] || { echo "ROW $r NO-CMDS" >> "$OUT"; continue; }
  key=$(echo "$r" | tr '/' '_'); w=$SCR/$key; rm -rf "$w"; mkdir -p "$w"
  # `verify_golden.py` runs slang with cwd = the TEST SOURCE dir, not the
  # workdir, so a command line naming relative sources must be replayed there.
  base=$(basename "$r"); base=${base%-*}
  run=$d
  for cand in "$HOME/git-repos/Surelog/tests/$base" \
              "$HOME/git-repos/Surelog/third_party/tests/$base" \
              "$HOME/git-repos/uhdm2rtlil/test/$base"; do
    [ -d "$cand" ] && run=$cand && break
  done
  line=$(sed -n 's/^slang: *//p' "$d/cmds.txt")
  args=${line#* }                                    # drop the binary path
  args=$(echo "$args" | sed 's|-o [^ ]*||')          # drop the -o and its path
  for tag in pris pat null; do
    case $tag in pris) B=$PRIS;; pat) B=$PATCHED;; null) B=$NULL;; esac
    ( cd "$run" && timeout 900 $B $args -o "$w/$tag.uhdm" > "$w/$tag.log" 2>&1 </dev/null ); rc=$?
    echo "ROW $r $tag rc=$rc md5=$(md5sum "$w/$tag.uhdm" 2>/dev/null | cut -c1-12)" >> "$OUT"
  done
  a=$(md5sum "$w/pris.uhdm" 2>/dev/null | cut -c1-12)
  b=$(md5sum "$w/pat.uhdm"  2>/dev/null | cut -c1-12)
  c=$(md5sum "$w/null.uhdm" 2>/dev/null | cut -c1-12)
  v="?"
  if [ "$a" = "$b" ]; then v="PAT-SAME-AS-PRIS"
  elif [ "$a" != "$c" ]; then v="LAYOUT-CLASS (the null control moves too)"
  else v="LAW-CLASS (the null control does NOT move)"; fi
  echo "VERDICT $r pris=$a pat=$b null=$c $v" >> "$OUT"
  rm -f "$w"/*.uhdm
done
grep -c '^VERDICT' "$OUT"; true
