#!/usr/bin/env bash
# r10buvm8repro/bndarms8.sh — THE BOUNDARY GATE.  Every arm source of the
# ADJACENT passes is compiled by BOTH binaries and the two databases are
# BYTE-compared; a byte-identical pair proves that pass's arms are untouched
# without re-reading its tables.  Where bytes DO move, the cmp head count is
# printed for both so a regression cannot hide behind "it moved a little".
#
#   usage: PRISTINE=... PATCHED=... ./bndarms8.sh <repro-dir> [<repro-dir> ...]
#
# GUARDS:
#   * a source SLANG-REJECTED by BOTH binaries is reported REJECT-BOTH and
#     counted, never silently skipped -- an arm that compiles on neither binary
#     proves nothing and must not read as "identical".
#   * Surelog synthesizes builtin.sv in the CWD, so each run gets its own dir.
#   * the two binaries' md5s are printed.
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
echo "PRISTINE md5=$(md5sum "$PRISTINE"|cut -c1-12)  PATCHED md5=$(md5sum "$PATCHED"|cut -c1-12)"
same=0; moved=0; rej=0
printf "%-22s %-26s %-10s %s\n" REPRO ARM BYTES NOTE
for d in "$@"; do
  for src in "$d"/*.sv; do
    [ -f "$src" ] || continue
    b=$(basename "$src" .sv)
    W=/tmp/vbuvm8_bnd_$(basename "$d")_$b
    # BOTH BINARIES RUN IN THE *SAME* DIRECTORY.  The first version of this
    # script gave each binary its own subdir and every single arm read as MOVED
    # with heads 0/0 on both sides -- because a UHDM database records the
    # SOURCE FILE's absolute path, so two different CWDs guarantee different
    # bytes for identical models.  A byte comparator whose two inputs differ by
    # construction reports 100% movers and proves nothing.
    rm -rf "$W"; mkdir -p "$W" || exit 3
    cp "$src" "$W/"
    (cd "$W" && "$PRISTINE" "$b.sv" -o p.uhdm >p.log 2>&1)
    (cd "$W" && "$PATCHED"  "$b.sv" -o q.uhdm >q.log 2>&1)
    if [ ! -f "$W/p.uhdm" ] && [ ! -f "$W/q.uhdm" ]; then
      printf "%-22s %-26s %-10s %s\n" "$(basename "$d")" "$b" - "REJECT-BOTH"; rej=$((rej+1)); continue
    fi
    if [ ! -f "$W/p.uhdm" ] || [ ! -f "$W/q.uhdm" ]; then
      printf "%-22s %-26s %-10s %s\n" "$(basename "$d")" "$b" - "ONE-SIDE-ONLY(REGRESSION)"; moved=$((moved+1)); continue
    fi
    if cmp -s "$W/p.uhdm" "$W/q.uhdm"; then
      printf "%-22s %-26s %-10s %s\n" "$(basename "$d")" "$b" IDENTICAL ""; same=$((same+1))
    else
      # bytes moved: measure BOTH heads against this arm's own Surelog golden
      (cd "$W" && "$SURELOG" -parse -nocache -mt 0 -mp 0 "$b.sv" >sl.log 2>&1)
      hp=-; hq=-; lp=-; lq=-
      if [ -f "$W/slpp_all/surelog.uhdm" ]; then
        hp=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/p.uhdm" 2>/dev/null | grep -c '^LHS:')
        hq=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/q.uhdm" 2>/dev/null | grep -c '^LHS:')
        lp=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/p.uhdm" 2>/dev/null | wc -l)
        lq=$("$CMP" "$W/slpp_all/surelog.uhdm" "$W/q.uhdm" 2>/dev/null | wc -l)
      fi
      printf "%-22s %-26s %-10s %s\n" "$(basename "$d")" "$b" MOVED "heads pristine=$hp patched=$hq  cmplines $lp -> $lq"
      moved=$((moved+1))
    fi
  done
done
echo "-- arms IDENTICAL=$same MOVED=$moved REJECT-BOTH=$rej"
