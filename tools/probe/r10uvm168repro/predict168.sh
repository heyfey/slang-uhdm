#!/usr/bin/env bash
# r10uvm168repro/predict168.sh — THE A-PRIORI MOVER PREDICTION.  MEASUREMENT ONLY.
#   predict168.sh <sweep-workdir> <binary> <out.txt> [<extra env assignments>]
#
# Re-runs each row's OWN `slang:` command line (read out of its `cmds.txt`, so
# the argument set is the harness's and not a guess) with the NAMED binary and
# `R10E168_DBG=1`, and collects every § enumOriginConstTypeIsTheMemberValue168
# firing.  Run it with `R10E168_OFF=1` and the binary behaves exactly as the
# PRISTINE one does, so the firing list is a prediction made BEFORE the law is
# allowed to move anything — RESUME §6, "PREDICT the mover set BY NAME from
# pristine databases FIRST".
#
# GUARDS: the binary is SUBSTITUTED into the recorded command line and the
# substitution is echoed, so the run cannot silently use the main-tree binary;
# every rc is recorded (an rc>128 SEGFAULT must never read as "no firings");
# a row whose cmds.txt has no `slang:` line is counted as SKIPPED.
set -u
WD=${1:?workdir}; BIN=${2:?binary}; OUT=${3:?out}
[ -x "$BIN" ] || { echo "FATAL no binary $BIN"; exit 3; }
SC=${SCRATCH:-/tmp/r10uvm168_predict_scratch}
# NEVER clear a directory that is not this pass's own scratch: a driver that
# `rm -rf`s a caller-supplied path can take another pass's work with it.
case "$SC" in
  /tmp/r10uvm168_*) ;;
  *) echo "FATAL: SCRATCH must be a /tmp/r10uvm168_* path, got '$SC'"; exit 3;;
esac
rm -rf "$SC"; mkdir -p "$SC"
: > "$OUT"; : > "$OUT.rc"
echo "PREDICT binary=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1) env=[${R10E168_OFF:+R10E168_OFF=$R10E168_OFF }R10E168_DBG=1]" >> "$OUT"
rows=0; skipped=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    n=$(basename "$d")
    C=$d/cmds.txt
    [ -f "$C" ] || { skipped=$((skipped+1)); continue; }
    line=$(grep -m1 '^slang:  *' "$C" || true)
    [ -n "$line" ] || { skipped=$((skipped+1)); continue; }
    # drop the "slang:   " tag and the recorded binary path (field 2), then
    # rewrite the -o target into this run's own scratch.
    args=$(printf '%s\n' "$line" | sed 's/^slang:  *//')
    set -- $args
    shift                                  # the recorded binary path
    outp="$SC/$mode.$n.uhdm"
    newargs=""
    skipnext=0
    for a in "$@"; do
      if [ "$skipnext" = 1 ]; then skipnext=0; continue; fi
      if [ "$a" = "-o" ]; then skipnext=1; continue; fi
      newargs="$newargs $a"
    done
    src=$(sed -n 's/^# *dir: *//p' "$C" 2>/dev/null | head -1)
    ( cd "$d" && R10E168_DBG=1 "$BIN" $newargs -o "$outp" >/dev/null 2>"$SC/err.txt" </dev/null )
    rc=$?
    echo "rc=$rc $mode/$n" >> "$OUT.rc"
    grep '^R10E168 ' "$SC/err.txt" 2>/dev/null | sed "s#^#$mode/$n #" >> "$OUT" || true
    rows=$((rows+1))
  done
done
echo "PREDICTRUN rows=$rows skipped=$skipped firings=$(grep -c ' R10E168 ' "$OUT"; true)" | tee -a "$OUT"
awk '{c[$1]++} END {for (k in c) printf "%s %d\n", k, c[k]}' "$OUT.rc" | sort
