#!/bin/bash
# r10uvm41 — byte-compare the UVM-4 databases of two sweep workdirs.  Used to
# prove that the FINAL build (after the refuted § assocIndexAliasDefView41 was
# reverted) is bit-for-bit the build that carried the four hard gates.
#   usage: cmpwd.sh <workdir-a> <workdir-b>
set -u
A=${1:?}
B=${2:?}
same=0; diff=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  da=$(ls -d "$A"/default/$T-* 2>/dev/null | head -1)
  db=$(ls -d "$B"/default/$T-* 2>/dev/null | head -1)
  [ -n "$da" ] && [ -n "$db" ] || { echo "$T: missing"; continue; }
  ha=$(sha256sum "$da/slang.uhdm" | cut -d' ' -f1)
  hb=$(sha256sum "$db/slang.uhdm" | cut -d' ' -f1)
  if [ "$ha" = "$hb" ]; then echo "$T IDENTICAL ${ha:0:12}"; same=$((same+1));
  else echo "$T DIFFER ${ha:0:12} vs ${hb:0:12}"; diff=$((diff+1)); fi
done
echo "identical=$same differ=$diff"
