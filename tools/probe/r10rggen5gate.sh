#!/bin/bash
# r10rggen5gate: the three gate legs.  usage: r10rggen5gate.sh {gold|u2r|sl}
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_c688bbce-626-1
export SLANG_UHDM=$W/build/slang-uhdm
case "$1" in
  gold)
    cd $W
    ./tests/check_goldens.sh > /tmp/r10rggen5_gold.txt 2>&1
    echo "PASS=$(grep -c '^PASS' /tmp/r10rggen5_gold.txt)"
    grep -v '^PASS' /tmp/r10rggen5_gold.txt | head -20
    ;;
  u2r)
    rm -rf /tmp/r10rggen5_u2rw
    python3 $W/scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags \
      --out /tmp/r10rggen5_u2r.csv --workdir /tmp/r10rggen5_u2rw --jobs 6 \
      > /tmp/r10rggen5_u2r.log 2>&1
    echo "lines=$(wc -l < /tmp/r10rggen5_u2r.csv)"
    diff <(sort $W/results/gate_uhdm2rtlil.csv) <(sort /tmp/r10rggen5_u2r.csv) \
      > /tmp/r10rggen5_u2r.diff
    echo "diff=$(grep -c '^[<>]' /tmp/r10rggen5_u2r.diff)"
    head -40 /tmp/r10rggen5_u2r.diff
    ;;
  sl)
    rm -rf /tmp/r10rggen5_slw
    python3 $W/scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/r10rggen5_sl.csv --workdir /tmp/r10rggen5_slw --jobs 6 \
      > /tmp/r10rggen5_sl.log 2>&1
    echo "lines=$(wc -l < /tmp/r10rggen5_sl.csv)"
    diff <(sort $W/results/golden_surelog.csv) <(sort /tmp/r10rggen5_sl.csv) \
      > /tmp/r10rggen5_sl.diff
    echo "diff=$(grep -c '^[<>]' /tmp/r10rggen5_sl.diff)"
    head -80 /tmp/r10rggen5_sl.diff
    ;;
esac
