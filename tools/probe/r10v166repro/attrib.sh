#!/usr/bin/env bash
# r10v166 VERIFIER — ORDER-BLIND attribution of ONE mover.
#   attrib.sh <rel path under the two workdirs>
# Both databases are dumped, the WORKDIR PATH is normalised away (dumps embed
# it), both sides are SORTED, and the diff is counted.  0 lines => the mover is
# the Scoreboard/default COIN and nothing else; otherwise every differing line
# must be one the law names.
set -u
REL=$1
P=/tmp/v166_wd/slp/$REL/slang.uhdm
Q=/tmp/v166_wd/slq/$REL/slang.uhdm
D=$HOME/git-repos/UHDM/build/bin/uhdm-dump
O=/tmp/v166_wd/attrib/$(echo "$REL" | tr / _)
mkdir -p "$O"
"$D" "$P" 2>/dev/null | sed 's#/tmp/v166_wd/slp#WD#g; s#, id:[0-9]*##g' | sort > "$O/p.txt"
"$D" "$Q" 2>/dev/null | sed 's#/tmp/v166_wd/slq#WD#g; s#, id:[0-9]*##g' | sort > "$O/q.txt"
echo "$REL  lines_pris=$(wc -l < "$O/p.txt")  lines_pat=$(wc -l < "$O/q.txt")"
diff "$O/p.txt" "$O/q.txt" > "$O/d.txt"; echo "  ORDER-BLIND DIFF LINES: $(grep -c '^[<>]' "$O/d.txt"; true)"
grep '^[<>]' "$O/d.txt" | sed 's/[0-9][0-9]*/N/g' | sort | uniq -c | sort -rn | head -30
