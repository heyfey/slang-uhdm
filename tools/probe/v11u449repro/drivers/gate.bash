#!/bin/bash
# gate.bash <binary> <workdir> <tracedir>: wait for three quiet readings 60 s apart, then the five stages
B=$1; W=$2; T=$3
source /tmp/v11u449_env.sh || exit 1
[ -x "$B" ] || exit 1
q=0
while [ $q -lt 3 ]; do
  n=$(pgrep -af 'sweep.sh|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests|svtests_matrix' | grep -v -e v11u449 -e pgrep | wc -l)
  if [ "$n" = 0 ]; then q=$((q+1)); else q=0; fi
  echo "$(date +%T) live=$n quiet=$q"
  sleep 60
done
export SLANG_UHDM=$B R11U449_TRACE=$T
mkdir -p $T
echo "START $(date +%T) $(md5sum $B)"
cd /tmp/wt_v11u449 && bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream"
echo "CORPUS_DONE rc=$? $(date +%T)"
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $W/svtests \
   --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u449/results/golden_svtests.csv
echo "SVTESTS_DONE rc=$? $(date +%T)"
