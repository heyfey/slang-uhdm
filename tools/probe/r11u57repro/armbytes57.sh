#!/usr/bin/env bash
# r11u57 ARM BYTES — which grid arms' DATABASES moved between two binaries.
#
# `toward57.sh` says whether an arm moved toward golden; this says whether it
# moved AT ALL.  The fenced arms (`e4_typedef57`, the W3 cell whose elaborated
# polarity is the opposite of this law's; `e5_genblock57`, out of both halves'
# reach) must read SAME, and an arm reading SAME that the law was supposed to
# move is just as much a failure — so every arm is printed, not only the
# surprises.
#
#   usage: armbytes57.sh <tagA> <tagB>        (e.g. base law)
set -u
R=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
A=${1:?tagA}; B=${2:?tagB}
printf "%-18s %-14s %-14s %s\n" ARM "$A" "$B" VERDICT
for a in $(ls -d $R/grid/*/ | xargs -n1 basename | sort -V); do
  fa=$R/grid/$a/ours.$A.uhdm; fb=$R/grid/$a/ours.$B.uhdm
  if [ ! -f "$fa" ] || [ ! -f "$fb" ]; then
    printf "%-18s %-14s %-14s %s\n" "$a" - - NO-DATABASE; continue
  fi
  ma=$(md5sum "$fa" | cut -c1-12); mb=$(md5sum "$fb" | cut -c1-12)
  v=MOVED; [ "$ma" = "$mb" ] && v=SAME
  printf "%-18s %-14s %-14s %s\n" "$a" "$ma" "$mb" "$v"
done
