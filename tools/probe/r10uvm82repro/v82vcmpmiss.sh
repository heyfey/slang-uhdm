#!/usr/bin/env bash
# multiset line-level MISSING/EXTRA per arm, pristine vs patched.
# REGRESSED = a golden line ours produced BEFORE and no longer produces.
set -u
printf "%-5s %8s %8s %8s %8s %8s %8s\n" ARM MISS_B EXTRA_B MISS_A EXTRA_A REGRESS LOST_EXTRA
for n in "$@"; do
  P=/tmp/v82_arm_pris_v$n; Q=/tmp/v82_arm_pat_v$n
  [ -f $P/g.dump ] && [ -f $Q/g.dump ] || { echo "v$n SKIP"; continue; }
  # normalise workdir paths out
  for f in g o; do
    sed "s#/tmp/v82_arm_pris_v$n#WD#g" $P/$f.dump | sort > /tmp/v82_ms.${f}b
    sed "s#/tmp/v82_arm_pat_v$n#WD#g"  $Q/$f.dump | sort > /tmp/v82_ms.${f}a
  done
  comm -23 /tmp/v82_ms.gb /tmp/v82_ms.ob > /tmp/v82_ms.missb
  comm -13 /tmp/v82_ms.gb /tmp/v82_ms.ob > /tmp/v82_ms.extrab
  comm -23 /tmp/v82_ms.ga /tmp/v82_ms.oa > /tmp/v82_ms.missa
  comm -13 /tmp/v82_ms.ga /tmp/v82_ms.oa > /tmp/v82_ms.extraa
  R=$(comm -13 /tmp/v82_ms.missb /tmp/v82_ms.missa | wc -l)
  LE=$(comm -13 /tmp/v82_ms.extraa /tmp/v82_ms.extrab | wc -l)
  printf "v%-4s %8s %8s %8s %8s %8s %8s\n" "$n" \
    $(wc -l < /tmp/v82_ms.missb) $(wc -l < /tmp/v82_ms.extrab) \
    $(wc -l < /tmp/v82_ms.missa) $(wc -l < /tmp/v82_ms.extraa) "$R" "$LE"
  if [ "$R" -gt 0 ]; then echo "  --- REGRESSED lines (golden lines we lost):"; comm -13 /tmp/v82_ms.missb /tmp/v82_ms.missa | sed 's/^/    /' | head -12; fi
done
