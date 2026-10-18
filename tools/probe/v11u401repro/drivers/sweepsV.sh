#!/bin/bash
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
unset GOLDEN_DEFER
for tag in V; do
  export SLANG_UHDM=/tmp/v11u401_bin/slang-uhdm.v3
  wd=/tmp/v11u401_w$tag
  cd /tmp/wt_v11u401 && bash tests/sweep.sh --jobs 3 --workdir $wd --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u401_w$tag.log 2>&1
  echo "sweep rc=$?" >> /tmp/v11u401_w$tag.log
  python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $wd/svtests --out $wd/svtests.csv --svtests /home/heyfey/git-repos/sv-tests > /tmp/v11u401_w${tag}_sv.log 2>&1
  echo "svtests rc=$?" >> /tmp/v11u401_w${tag}_sv.log
done
