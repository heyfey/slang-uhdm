#!/bin/bash
# v11u207 (from r11u207repro): order-blind attribution of det.sh's draws: for each row-mode whose three hashes differ, the number of
# lines in the diff of the SORTED uhdm-dumps (paths normalised, ids stripped) between each pair of runs.
# usage: detob.sh <det out dir>   (fence: det.sh already refused fenced names; checked again here)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
O=$1
norm() { $UHDM_DUMP "$1" 2>/dev/null | sed -E 's#/tmp/v11u207_det[A-Z]*/w[0-9]#W#g; s/id:[0-9]+//g' | sort; }
for m in default testflags; do for d in $(ls -d $O/w1/$m/* 2>/dev/null); do
  t=$(basename $d | sed 's/-[0-9a-f]*$//'); for f in $FENCED; do [ "$t" = "$f" ] && continue 2; done
  a=$d/slang.uhdm; b=$(ls -d $O/w2/$m/$t-*)/slang.uhdm; c=$(ls -d $O/w3/$m/$t-*)/slang.uhdm
  [ "$(md5sum < $a)" = "$(md5sum < $b)" ] && [ "$(md5sum < $b)" = "$(md5sum < $c)" ] && { echo "$m/$t SAME"; continue; }
  norm $a > /tmp/v11u207_detob.1; norm $b > /tmp/v11u207_detob.2; norm $c > /tmp/v11u207_detob.3
  echo "$m/$t sorted-dump diff lines: 1v2=$(diff /tmp/v11u207_detob.1 /tmp/v11u207_detob.2 | grep -c '^[<>]') 1v3=$(diff /tmp/v11u207_detob.1 /tmp/v11u207_detob.3 | grep -c '^[<>]') 2v3=$(diff /tmp/v11u207_detob.2 /tmp/v11u207_detob.3 | grep -c '^[<>]')"
done; done
