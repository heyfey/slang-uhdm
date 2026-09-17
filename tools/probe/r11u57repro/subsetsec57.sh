#!/usr/bin/env bash
# r11u57 SUBSET PROVER, SECTIONED — "MOVED-WRONG 0 / AWAY-GOLDEN 0" over the
# JUDGE-REACHABLE dump only.
#
# `subset57.sh` (inherited from r11u53) compares the whole dump, tail included.
# The `weaklyReferenced:` TAIL is unreachable to `uhdm-cmp` (RESUME §9), and it
# holds parked copies whose NESTING DEPTH — and therefore the dump's leading
# whitespace — changes when an object changes kind, which shows up in a sorted
# whole-dump diff as brand-new line texts that no judge can see.  This prover
# cuts the dump at `uhdmallModules:` … `weaklyReferenced:` first, so the answer
# is about the two listings the judge walks.  Run it BESIDE `subset57.sh`, never
# instead of it: a difference between the two answers is exactly a tail-only
# move and must be reported as one.
#
#   usage: subsetsec57.sh <pristine rowdir> <patched rowdir>
set -u
P=${1:?pristine rowdir}; Q=${2:?patched rowdir}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
t=$(mktemp -d)
gold() { sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$1/cmds.txt" | head -1; }
sec() { awk '/uhdmallModules:/{f=1} /weaklyReferenced:/{f=0} f' "$1"; }
norm() { sed 's/, id:[0-9]*//g; s/id:[0-9]*//g; s/  */ /g'; }
G=$(gold "$Q")/golden.uhdm
[ -f "$G" ] || { echo "FATAL no golden for $Q"; exit 3; }
$DUMP "$G" 2>/dev/null | sed 's#/home/heyfey/[^ ,)]*/##g' > "$t/g"
$DUMP "$P/slang.uhdm" 2>/dev/null | sed "s#$P/##g;s#/home/heyfey/[^ ,)]*/##g" > "$t/b"
$DUMP "$Q/slang.uhdm" 2>/dev/null | sed "s#$Q/##g;s#/home/heyfey/[^ ,)]*/##g" > "$t/p"
sec "$t/g" | sort > "$t/gs"
for x in b p; do sec "$t/$x" | sort > "$t/${x}s"; diff "$t/gs" "$t/${x}s" > "$t/${x}.d"; true; done
bg=$(grep -c '^<' "$t/b.d"; true); bo=$(grep -c '^>' "$t/b.d"; true)
pg=$(grep -c '^<' "$t/p.d"; true); po=$(grep -c '^>' "$t/p.d"; true)
grep -E '^[<>]' "$t/b.d" | norm | sort -u > "$t/bt"
grep -E '^[<>]' "$t/p.d" | norm | sort -u > "$t/pt"
new=$(comm -13 "$t/bt" "$t/pt" | grep -c .; true)
echo "$(basename "$Q")"
echo "  judge sections: pristine gonly=$bg oonly=$bo  ->  patched gonly=$pg oonly=$po"
echo "  divergence texts: pristine=$(wc -l < "$t/bt") patched=$(wc -l < "$t/pt") NOT-PRESENT-BEFORE=$new"
[ "$new" != 0 ] && comm -13 "$t/bt" "$t/pt" | sed 's/^/    NEW /'
rm -rf "$t"
[ "$new" = 0 ]
