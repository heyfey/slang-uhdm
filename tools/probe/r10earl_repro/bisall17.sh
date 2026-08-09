#!/bin/bash
# bisall17.sh -- run the generic bisector (r10earl17c) over every head and
# collect the FIELD CHAINS in one file.  ~1 min per head (two 50MB Restores
# dominate), so run it detached and read the result.  EARL_OURS picks the
# database; the head list is the pass-17 exit census.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_a5fb2b31-52f-1
B=$W/tools/probe/r10earl_repro/bis17.sh
for M in work@hmac work@sha2 work@flash_phy_core work@prim_prince \
         work@dm_mem work@flash_mp work@padring work@top_earlgrey; do
  echo "##### all $M"
  timeout 900 bash "$B" all "$M" whole 2>&1 | grep -vE '^      rel=|^        [AB] ' | tail -30
done
for T in work@sram2tlul work@jtag_mux work@padring work@prim_gate_gen \
         work@prim_prince work@prim_present work@prim_keccak work@top_earlgrey; do
  echo "##### top $T"
  timeout 900 bash "$B" top "$T" whole 2>&1 | grep -vE '^      rel=|^        [AB] ' | tail -30
done
