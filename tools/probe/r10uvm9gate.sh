#!/bin/bash
# r10uvm9gate: the three-part hard gate from this worktree.
#   r10uvm9gate.sh goldens | u2r | sl
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_e4a1375e-b25-1
export SLANG_UHDM=$W/build/slang-uhdm
case "$1" in
  goldens)
    bash $W/tests/check_goldens.sh > /tmp/r10uvm9_goldens.txt 2>&1
    echo "PASS=$(grep -c '^PASS' /tmp/r10uvm9_goldens.txt) NONPASS=$(grep -vc '^PASS' /tmp/r10uvm9_goldens.txt)"
    grep -v '^PASS' /tmp/r10uvm9_goldens.txt | head -10
    ;;
  u2r)
    rm -rf /tmp/r10uvm9_u2rw
    timeout 3600 python3 $W/scripts/verify_golden.py --corpus uhdm2rtlil \
      --mode testflags --out /tmp/r10uvm9_u2r.csv --workdir /tmp/r10uvm9_u2rw \
      --jobs 4 2>&1 | tail -8
    echo "--- diff vs results/gate_uhdm2rtlil.csv ---"
    diff <(sort $W/results/gate_uhdm2rtlil.csv) <(sort /tmp/r10uvm9_u2r.csv) | head -40
    echo "difflines=$(diff <(sort $W/results/gate_uhdm2rtlil.csv) <(sort /tmp/r10uvm9_u2r.csv) | grep -c '^[<>]')"
    ;;
  sl)
    rm -rf /tmp/r10uvm9_slw
    timeout 7200 python3 $W/scripts/verify_golden.py --corpus surelog --mode both \
      --out /tmp/r10uvm9_sl.csv --workdir /tmp/r10uvm9_slw --jobs 4 2>&1 | tail -20
    echo "--- diff vs results/golden_surelog.csv ---"
    diff <(sort $W/results/golden_surelog.csv) <(sort /tmp/r10uvm9_sl.csv) > /tmp/r10uvm9_sl.diff
    echo "difflines=$(grep -c '^[<>]' /tmp/r10uvm9_sl.diff)"
    head -60 /tmp/r10uvm9_sl.diff
    ;;
esac
