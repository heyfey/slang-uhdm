#!/bin/bash
# r10uvm20pres.sh [oursdir] [pairfilter] — the PRESENCE census over the UVM-4.
# Histograms every failing pair as "<part> | <Lkind> vs <Rkind> | <verdict>",
# where the verdict answers the one question a presence row cannot: does the
# object the other side names EXIST over here?
#   ABSENT    nothing of that name anywhere on the other side (emission gap)
#   NOLOC(n)  the name exists, but not at that span
#   KIND=k    the very object exists at that exact span — a BINDING difference
#   BOTH      not a presence row (both sides non-null); ANON = unnamed object
# With a pair filter (e.g. 'io_decl vs <null>') it prints the rows themselves,
# each with both sides' VpiParent chain, instead of the histogram.
#
# Build the probe with
#   g++ -O2 -std=c++20 -I$HOME/.local/include -o /tmp/r10uvm20_pres \
#       tools/probe/r10uvm20b.cpp -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread
# and create the sweep workdir the goldens come from with
#   python3 scripts/verify_golden.py --corpus surelog --mode default \
#     --filter '^(BuildUVMPkg|Scoreboard|SeqDriver|SimpleUVM)$' \
#     --out /tmp/r10uvm20_u4.csv --workdir /tmp/r10uvm20_u4w --jobs 2
# then emit ours with tools/probe/r10uvm19m.sh.
set -u
O=${1:-/tmp/r10uvm20_m}
F=${2:-}
B=${R10P:-/tmp/r10uvm20_pres}
SW=${R10W:-/tmp/r10uvm20_u4w}
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d $SW/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir" >&2; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  "$B" "$G" "$O/$T.uhdm" pres "" "$F" 2>/dev/null
done | {
  if [ -n "$F" ]; then cat
  else awk -F'  *' '{n=$1; $1=""; sub(/^ +/,""); c[$0]+=n}
         END{for (k in c) printf "%8d  %s\n", c[k], k}' | sort -rn | head -${N:-40}
  fi
}
