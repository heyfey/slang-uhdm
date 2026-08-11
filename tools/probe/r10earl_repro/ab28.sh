#!/bin/bash
# ab28.sh <witness-basename> -- the A/B the two pass-28 env gates exist for.
# Emits ours-vs-golden param_assign deltas for FOUR binaries-in-one:
#   BOTH  = both laws on (the shipped behaviour)
#   TERN  = only the ternary arm
#   SCAL  = only the scalar-source skip
#   NONE  = pre-pass-28 behaviour
# so "is this row a REGRESSION or PRE-EXISTING?" is answered by reading the
# NONE column, not by rebuilding.  A row that differs under NONE is
# PRE-EXISTING; a row that agrees under NONE and differs under BOTH is a
# REGRESSION THIS PASS CAUSED.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_0498617d-9bf-1
P=$W/tools/probe/r10earl_repro
F=$1
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
D=/tmp/r10earl28_ab_$F
rm -rf "$D"; mkdir -p "$D"
mkdir -p /tmp/r10earl28_ab
cd /tmp/r10earl28_ab || exit 1
$SL -parse -nocache -mt 0 -mp 0 -d uhdm "$P/$F.sv" -o "$D/sl" > "$D/sl.log" 2>&1
G=$(ls "$D"/sl/slpp_all/*.uhdm 2>/dev/null | head -1)
/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump "$G" > "$D/g.dump" 2>&1
python3 "$P/pav28.py" "$D/g.dump" > "$D/g.txt"
run() {  # <tag> <env...>
  local t=$1; shift
  env "$@" "$W/build/slang-uhdm" "$P/$F.sv" -o "$D/$t.uhdm" > "$D/$t.log" 2>&1
  /home/heyfey/git-repos/UHDM/build/bin/uhdm-dump "$D/$t.uhdm" > "$D/$t.dump" 2>&1
  python3 "$P/pav28.py" "$D/$t.dump" > "$D/$t.txt"
  echo "$t: $(diff "$D/g.txt" "$D/$t.txt" | grep -c '^<') rows differ from golden"
}
run BOTH R10E28_X=0
run TERN R10E28_NOSCALARSKIP=1
run SCAL R10E28_NOTERNARM=1
run NONE R10E28_NOSCALARSKIP=1 R10E28_NOTERNARM=1
echo "--- ROWS THIS PASS REGRESSED (agree under NONE, differ under BOTH):"
comm -13 <(diff "$D/g.txt" "$D/NONE.txt" | grep '^<' | sort) \
         <(diff "$D/g.txt" "$D/BOTH.txt" | grep '^<' | sort)
echo "--- ROWS THIS PASS FIXED (differ under NONE, agree under BOTH):"
comm -23 <(diff "$D/g.txt" "$D/NONE.txt" | grep '^<' | sort) \
         <(diff "$D/g.txt" "$D/BOTH.txt" | grep '^<' | sort)
