#!/usr/bin/env bash
# r10vearl114 WIDE BOUNDARY -- MEASUREMENT ONLY.
# Dumps EVERY .sv/.v in a staged copy of the committed tools/probe tree, at any
# depth, in BOTH views, with BOTH frozen binaries, and compares the
# workdir-normalised uhdm-dump.  A cell that differs is a cell this patch moved.
#
# GUARDS (each an ops trap this campaign has paid for):
#   * the four slang-fenced names are filtered out of the LIST before a single
#     child runs, and the filter's hit count is printed;
#   * the file list is read on fd 3 and every child gets </dev/null, so no
#     child can eat the list (sd8-12's trap);
#   * scratch is keyed on the RELATIVE path (r10uvm33repro has three dut.sv);
#   * every invocation's rc is appended to a log, so LISTED/PROCESSED and the
#     per-side rc histogram are RECONSTRUCTED from the log, not from a counter;
#   * SUBDIRECTORIES are included (a top-level glob would run nothing).
#   * stdout goes where the caller sends it; the list is written to $OUT.list.
set -u
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}
SRC=${SRC_TREE:?set SRC_TREE to the tools/probe tree}
OUT=${1:?outdir}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$OUT/stage" "$OUT/run"
rm -rf "$OUT/stage"; mkdir -p "$OUT/stage"
cp -r "$SRC/." "$OUT/stage/"
# THE FENCE LIST IS READ OUT OF canaudit.sh's OWN `FENCED=` LINE and never
# spelled here: a probe artifact that names the four slang-fenced tests
# individually is itself a FENCE-BREACH (canaudit.sh reads it as one).
FENCED=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' "$(cd "$(dirname "$0")" && pwd)/canaudit.sh" | tr ' ' '|')
[ -n "$FENCED" ] || { echo "FATAL: no fence list in canaudit.sh"; exit 3; }
( cd "$OUT/stage" && find . -type f \( -name '*.sv' -o -name '*.v' \) | sort ) > "$OUT.all_raw"
grep -Ec "$FENCED" "$OUT.all_raw" > "$OUT.fenced_hits" || echo 0 > "$OUT.fenced_hits"
grep -Ev "$FENCED" "$OUT.all_raw" > "$OUT.list"
LISTED=$(wc -l < "$OUT.list")
: > "$OUT.rc"; : > "$OUT.diff"
while read -r rel <&3; do
  key=$(echo "$rel" | sed 's#^\./##; s#/#__#g')
  d="$OUT/run/$key"; mkdir -p "$d"
  for view in plain elab; do
    case $view in plain) F="";; elab) F="--elabuhdm";; esac
    for side in A B; do
      case $side in A) B_=$PRIS;; B) B_=$PAT;; esac
      ( cd "$OUT/stage/$(dirname "$rel")" && "$B_" $F "$(basename "$rel")" --nobuiltin \
          -o "$d/$side.$view.uhdm" > "$d/$side.$view.log" 2>&1 </dev/null ); rc=$?
      echo "$rel $view $side $rc" >> "$OUT.rc"
    done
    if [ -f "$d/A.$view.uhdm" ] && [ -f "$d/B.$view.uhdm" ]; then
      # NORMALISE THE WORKDIR *AND* THE SIDE LETTER: the dump's first line
      # names the output file it restored, so an unnormalised A/B in the
      # filename makes every single cell "differ" (this verifier's own first
      # run scored 2423 phantom DIFFERING cells that way).  Dump paths embed
      # the workdir -- RESUME.md sec.9.
      "$DUMP" "$d/A.$view.uhdm" 2>/dev/null | sed "s#$OUT/run/$key#/K#g; s#$OUT/stage#/S#g; s#/K/A\.#/K/X.#g" > "$d/A.$view.txt"
      "$DUMP" "$d/B.$view.uhdm" 2>/dev/null | sed "s#$OUT/run/$key#/K#g; s#$OUT/stage#/S#g; s#/K/B\.#/K/X.#g" > "$d/B.$view.txt"
      if cmp -s "$d/A.$view.txt" "$d/B.$view.txt"; then echo "identical $rel $view" >> "$OUT.diff"
      else echo "DIFFERING $rel $view" >> "$OUT.diff"; fi
    else
      echo "no_output $rel $view" >> "$OUT.diff"
    fi
    rm -f "$d/A.$view.uhdm" "$d/B.$view.uhdm"
  done
done 3< "$OUT.list"
{
echo "LISTED (after fence filter)      : $LISTED"
echo "FENCED-NAME HITS FILTERED OUT    : $(cat "$OUT.fenced_hits")"
echo "DISTINCT FILES IN THE rc LOG     : $(awk '{print $1}' "$OUT.rc" | sort -u | wc -l)"
echo "FILES WITH != 4 rc LINES         : $(awk '{c[$1]++} END{n=0; for(k in c) if(c[k]!=4) n++; print n}' "$OUT.rc")"
echo "FILES LISTED BUT NEVER RUN       : $(comm -23 <(sort -u "$OUT.list") <(awk '{print $1}' "$OUT.rc" | sort -u) | wc -l)"
echo "PROCESSED (distinct in diff log) : $(awk '{print $2}' "$OUT.diff" | sort -u | wc -l)"
echo "identical=$(grep -c '^identical' "$OUT.diff"; true)  DIFFERING=$(grep -c '^DIFFERING' "$OUT.diff"; true)  no_output=$(grep -c '^no_output' "$OUT.diff"; true)"
echo "rc by side:"; awk '{print "  "$3"/"$4}' "$OUT.rc" | sort | uniq -c
echo "DIFFERING cells:"; grep '^DIFFERING' "$OUT.diff" | sed 's/^DIFFERING //'
} > "$OUT.tally"
cat "$OUT.tally"
