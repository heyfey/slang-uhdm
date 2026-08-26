#!/usr/bin/env bash
# r10v160repro/vnewwrong160.sh — the ADDED lines our patched database has that
# GOLDEN DOES NOT.  These are the law's own residues made visible: an object we
# now mint that golden spells differently.  MEASUREMENT ONLY.
set -u
A=$1; B=$2; rel=$3
D=$HOME/git-repos/UHDM/build/bin/uhdm-dump
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$A/$rel/cmds.txt" | head -1); G=$G/golden.uhdm
T=$(mktemp -d /tmp/v160_nw_XXXXXX)
"$D" "$G" 2>/dev/null | sed -e 's#, id:[0-9]*##g' -e 's#file:[^,]*,##g' | sort > "$T/g"
"$D" "$A/$rel/slang.uhdm" 2>/dev/null | sed -e 's#, id:[0-9]*##g' -e 's#file:[^,]*,##g' -e "s#$A/##g" | sort > "$T/a"
"$D" "$B/$rel/slang.uhdm" 2>/dev/null | sed -e 's#, id:[0-9]*##g' -e 's#file:[^,]*,##g' -e "s#$B/##g" | sort > "$T/b"
comm -13 "$T/a" "$T/b" | sort > "$T/added"
echo "--- $rel: ADDED lines GOLDEN DOES NOT HAVE ---"
comm -23 "$T/added" "$T/g"
rm -rf "$T"
