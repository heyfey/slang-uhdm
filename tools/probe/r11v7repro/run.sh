#!/bin/bash
# r11v7 (ADVERSARIAL VERIFIER of r11u7) — rebuild every x-arm's REAL Surelog
# v1.87 golden and score the Compare-visible param_assign census of up to three
# binaries against it.
#
#   usage: run.sh <pristine-binary> <candidate-binary> [<fixed-binary>] [arm-root]
#
# A LOST line is a REGRESSION.  Every arm records surelog rc, `[  ERROR] : 0`,
# slang rc, the official uhdm-cmp rc and its `^LHS:` head count.  x3 is the
# NON-COMPARABLE arm: slang accepts its type keys and Surelog v1.87 does not
# (surelog_rc=3, NO golden), so uhdm-cmp is run on a missing file and its rc 0
# means NOTHING — the arm's content is that both binaries emit the same bytes.
set -u
H=$(dirname "$(readlink -f "$0")")
P=$(readlink -f "${1:?pristine binary}")
Q=$(readlink -f "${2:?candidate binary}")
F=${3:-}
R=${4:-/tmp/r11v7_arms}
[ -n "$F" ] && F=$(readlink -f "$F")
ARMS="x1 x2 x3 x4 x5 x6 x7 x8"
mkdir -p "$R"
for a in $ARMS; do
  mkdir -p "$R/$a"; cp "$H/$a/dut.sv" "$R/$a/dut.sv"
  for m in plain elab; do
    bash "$H/armrun.sh" "$R/$a" pris_$m "$P" $m
    bash "$H/armrun.sh" "$R/$a" pat_$m  "$Q" $m
    [ -n "$F" ] && bash "$H/armrun.sh" "$R/$a" fix_$m "$F" $m
  done
done
echo
for a in $ARMS; do
  echo "=== $a (plain)"
  [ -f "$R/$a/w_pris_plain/golden.dump" ] || { echo "  NO GOLDEN (non-comparable arm)"; }
  python3 "$H/pacen7.py" "$R/$a/w_pris_plain/golden.dump" \
      "$R/$a/w_pris_plain/ours.dump" "$R/$a/w_pat_plain/ours.dump" 2>/dev/null |
    grep -E 'golden rows|agree|LOST|GAIN' || true
  if [ -n "$F" ]; then
    echo "  -- fixed binary vs pristine"
    python3 "$H/pacen7.py" "$R/$a/w_pris_plain/golden.dump" \
        "$R/$a/w_pris_plain/ours.dump" "$R/$a/w_fix_plain/ours.dump" 2>/dev/null |
      grep -E 'LOST|GAIN' || true
  fi
done
echo
echo "--- BYTE IDENTITY (the decline arms must match PRISTINE exactly)"
for a in $ARMS; do
  p=$(md5sum < "$R/$a/w_pris_plain/slang.uhdm" 2>/dev/null)
  q=$(md5sum < "$R/$a/w_pat_plain/slang.uhdm" 2>/dev/null)
  f=""; [ -n "$F" ] && f=$(md5sum < "$R/$a/w_fix_plain/slang.uhdm" 2>/dev/null)
  printf '%s  pat==pris:%s' "$a" "$([ "$q" = "$p" ] && echo YES || echo no)"
  [ -n "$F" ] && printf '  fix==pris:%s  fix==pat:%s' \
      "$([ "$f" = "$p" ] && echo YES || echo no)" \
      "$([ "$f" = "$q" ] && echo YES || echo no)"
  echo
done
