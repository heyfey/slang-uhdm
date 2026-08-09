#!/bin/bash
# suball15.sh -- sub-census (r10earl15b) of every § pkgTypespecInstanceIsTop head.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_4f18c51a-913-1
for M in work@hmac work@spi_device work@tlul_adapter_sram work@usbdev \
         work@prim_prince work@dm_mem work@rv_dm work@tlul_adapter_host \
         work@padring work@sha2 work@flash_phy_core; do
  echo "##### $M"
  bash "$W/tools/probe/r10earl_repro/sub15.sh" all "$M" -v 2>&1 |
    grep -E "^WHOLE|own=|SIZE" | head -14
done
