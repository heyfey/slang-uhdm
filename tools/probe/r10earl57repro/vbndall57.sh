#!/usr/bin/env bash
# r10earl57 WIDE (carried from r10earl54repro/vbndall54.sh) — WIDE BOUNDARY SWEEP — carried forward from r10earl53repro/vbndall53.sh
# with TWO changes, both of which the earl53 run's own output argued for:
#   * `--elabuhdm` is passed to BOTH binaries.  § connReplFoldNested54 lives on
#     the ELABORATED connection path, which a plain run never reaches; without
#     the flag the sweep is wide but BLIND to the law under test — it would
#     report "identical" for every arm and prove nothing.  It runs the plain
#     form too, so both views are covered.
#   * the differing list records WHICH view differed.
#
# EVERY .sv arm under tools/probe/*/ run with BOTH binaries (ours only, no
# Surelog); o.dump byte-compared after normalising the workdir path, which the
# dump embeds.
#
#   usage: vbndall55.sh <patched> <pristine>
set -u
PAT=${1:?patched}; PRIS=${2:?pristine}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=${PROBE_ROOT:-/home/heyfey/git-repos/slang-uhdm/tools/probe}
STAGE=/tmp/r10earl57_bndall; rm -rf "$STAGE"; mkdir -p "$STAGE"
n=0; same=0; diffn=0; noout=0
: > /tmp/r10earl57_bndall_diff.list
: > /tmp/r10earl57_bndall_signal.list
for f in "$ROOT"/*/*.sv $(cd "$(dirname "$0")" && pwd)/*.sv ; do
  [ -e "$f" ] || continue
  n=$((n+1))
  rel=$(echo "$f" | sed "s#$ROOT/##; s#/tmp/wt_r10earl57/tools/probe/##")
  key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}
  for view in plain elab; do
    case $view in plain) FLAGS="";; elab) FLAGS="--elabuhdm";; esac
    ok=1
    # BOTH SIDES ALWAYS RUN.  The first version `break`ed out of this loop the
    # moment side A (patched) failed, so side B (pristine) was never attempted
    # and the signal tally read `patched=4 pristine=0` — which looks exactly like
    # "this pass introduced four crashes" and is in fact NO MEASUREMENT OF THE
    # PRISTINE SIDE AT ALL.  Running both was what showed rc=139 on BOTH
    # binaries for r10uvm67repro/c3_iface.sv and v3_boundary.sv, i.e. a
    # pre-existing crash.  An asymmetric instrument cannot exonerate or convict.
    for side in A B; do
      case $side in A) BIN=$PAT;; B) BIN=$PRIS;; esac
      d="$STAGE/${key}_${view}_$side"; mkdir -p "$d"
      cp "$f" "$d/" 2>/dev/null || { ok=0; continue; }
      b=$(basename "$f")
      # EXIT CODE PER (arm, view, side), RECORDED.  The first run of this sweep
      # printed a bare `Segmentation fault` from the shell's job report with no
      # arm name attached, and the staging dir for a failed arm had already been
      # removed -- so "which arm, which binary" was UNANSWERABLE after the fact.
      # A crash that cannot be attributed to a side is indistinguishable from a
      # crash this pass introduced.
      ( cd "$d" && "$BIN" $FLAGS "$b" -o slang.uhdm >slang.log 2>&1 )
      rc=$?
      [ "$rc" -gt 128 ] && echo "SIGNAL rc=$rc $side($([ $side = A ] && echo patched || echo pristine)) $view $rel" \
        >> /tmp/r10earl57_bndall_signal.list
      [ -f "$d/slang.uhdm" ] || { ok=0; continue; }
      "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' \
        | sed "s#${key}_${view}_$side#WD#g" > "$d/o.norm"
      [ -s "$d/o.norm" ] || ok=0
    done
    if [ "$ok" = 0 ]; then
      noout=$((noout+1)); rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"; continue
    fi
    if cmp -s "$STAGE/${key}_${view}_A/o.norm" "$STAGE/${key}_${view}_B/o.norm"; then
      same=$((same+1)); rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"
    else
      diffn=$((diffn+1)); echo "$view $rel" >> /tmp/r10earl57_bndall_diff.list
    fi
  done
done
echo "WIDE BOUNDARY: runs=$((n*2)) arms=$n identical=$same DIFFERING=$diffn no_output=$noout"
echo "--- differing arms (view rel) ---"; cat /tmp/r10earl57_bndall_diff.list
echo "--- runs killed by a SIGNAL (side must be symmetric) ---"
cat /tmp/r10earl57_bndall_signal.list
echo "signal rows: patched=$(grep -c 'A(patched)' /tmp/r10earl57_bndall_signal.list; true) pristine=$(grep -c 'B(pristine)' /tmp/r10earl57_bndall_signal.list; true)"
