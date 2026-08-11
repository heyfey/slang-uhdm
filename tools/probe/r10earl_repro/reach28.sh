#!/bin/bash
# reach28.sh -- the CORPUS REACH of the two pass-28 laws, read off the
# R10E28_OVDBG trace at the branch point rather than guessed.  The witnesses
# are the POSITIVE CONTROL: `bash reach28.sh qc28` must print non-zero SCAL and
# TERN counts, otherwise the driver cannot find its probe and a zero on the
# corpus means nothing.
#   bash reach28.sh            -> Earlgrey_0_1 (the corpus)
#   bash reach28.sh <witness>  -> one witness .sv
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_0498617d-9bf-1
P=$W/tools/probe/r10earl_repro
if [ -n "$1" ]; then
  cd /tmp/r10earl28_rep || exit 1
  R10E28_OVDBG=1 "$W/build/slang-uhdm" "$P/$1.sv" -o /tmp/r10earl28_reach.uhdm \
      2> /tmp/r10earl28_reach.log > /dev/null
else
  SRC=$(grep -l 'lowrisc_systems_top_earlgrey' -r \
        /home/heyfey/git-repos/sv-tests/third_party/tools/Surelog/third_party/tests/Earlgrey_0_1 \
        --include='*.scr' 2>/dev/null | head -1)
  [ -n "$SRC" ] || { echo "scr not found"; exit 1; }
  cd "$(dirname "$SRC")" || exit 1
  R10E28_OVDBG=1 "$W/build/slang-uhdm" +define+SYNTHESIS -f "$(basename "$SRC")" \
      --single-unit -o /tmp/r10earl28_reach.uhdm \
      2> /tmp/r10earl28_reach.log > /dev/null
fi
echo "firings: $(grep -c '^R10E28' /tmp/r10earl28_reach.log)"
grep '^R10E28' /tmp/r10earl28_reach.log | awk '{print $2}' | sort | uniq -c
echo "--- distinct TERN sites"
grep '^R10E28 TERN' /tmp/r10earl28_reach.log | awk '{print $4, $5}' | sort -u | head -30
echo "--- distinct SCAL hop parameters"
grep '^R10E28 SCAL' /tmp/r10earl28_reach.log | awk '{print $4}' | sort | uniq -c \
  | sort -rn | head -30
