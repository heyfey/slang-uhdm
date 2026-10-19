#!/bin/bash
. /tmp/v11u403_scr/env.sh
quiet(){ until [ -z "$(pgrep -f 'sweep.sh|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests|svtests_matrix' | grep -v "^$$\$")" ]; do sleep 20; done; }
for t in ${@:-P L}; do
  if [ $t = P ]; then export SLANG_UHDM=/tmp/v11u403_pristine.bin; W=/tmp/v11u403_wdP; else export SLANG_UHDM=/tmp/v11u403_law.bin; W=/tmp/v11u403_wdL; fi
  [ -x "$SLANG_UHDM" ] || exit 9
  quiet; echo "$t start $(date) load $(cut -d' ' -f1-3 /proc/loadavg)"
  mkdir -p $W/svtrace; rm -rf $W/svtests
  ( cd /home/heyfey/git-repos/slang-uhdm && R11U403_TRACE=$W/svtrace python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests > $W/svtests.log 2>&1; echo "svtests rc=$?" >> $W/svtests.log )
  echo "$t end $(date)"; pgrep -af 'check_svtests|svtests_matrix|sweep.sh' | grep -v v11u403 | head -3
done
