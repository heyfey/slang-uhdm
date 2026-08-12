#!/bin/bash
# r10svs4repro/mv4.sh — attribute ONE byte-verifier mover PER SHAPE against
# GOLDEN, by MULTISET.
#
# The byte verifier says a database's bytes moved. That is not an attribution:
# it does not say whether we moved TOWARD golden or away, and `diff -u` cannot
# answer it either (it reports an ALIGNMENT, so a pure relocation prints as
# ADDED+REMOVED). This resolves the mover into per-shape multiset counts with
# golden as the third leg, via msmovers.sh.
#
#   usage: mv4.sh <mode> <TestName> <patched_wd_root> <pristine_wd_root>
#
# GUARDS:
#   * the GOLDEN database is found the way svsgen.sh finds it -- the local
#     slpp_all/slpp_unit copy, else the `golden cache hit` line in cmds.txt.
#     A missing golden is exit 6; it is never silently skipped, because a
#     two-leg comparison would still print plausible-looking numbers.
#   * uhdm-dump's FIRST LINE is the database path and always differs between
#     two roots, so all three dumps go through `sed 1d`.
#   * both workdir roots are existence-checked, and the two test dirs must have
#     the SAME basename (the harness hashes the argv into it, so a mismatch
#     means the two sweeps did not run the same command -- exit 4).
set -u
M=${1:?mode}
T=${2:?test name}
A=${3:?patched wd root}
B=${4:?pristine wd root}
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump"; exit 3; }
WA=$(ls -d "$A/$M/$T"-* 2>/dev/null | head -1)
WB=$(ls -d "$B/$M/$T"-* 2>/dev/null | head -1)
[ -n "${WA:-}" ] && [ -n "${WB:-}" ] || { echo "NO_WORKDIR for $M/$T"; exit 6; }
[ "$(basename "$WA")" = "$(basename "$WB")" ] || {
    echo "ARGV_HASH_MISMATCH $(basename "$WA") vs $(basename "$WB")"; exit 4; }
G=$(ls "$WA"/slpp_all/*.uhdm "$WA"/slpp_unit/*.uhdm 2>/dev/null | head -1)
if [ -z "${G:-}" ]; then
    C=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' "$WA/cmds.txt")
    G=$(ls "$C"/*.uhdm 2>/dev/null | head -1)
fi
[ -n "${G:-}" ] && [ -f "$G" ] || { echo "NO_GOLDEN for $M/$T"; exit 6; }
O=$(mktemp -d)
"$DUMP" "$G"                | sed '1d' > "$O/g.dump"
"$DUMP" "$WB/slang.uhdm"    | sed '1d' > "$O/p.dump"
"$DUMP" "$WA/slang.uhdm"    | sed '1d' > "$O/a.dump"
for f in g p a; do
    [ -s "$O/$f.dump" ] || { echo "EMPTY DUMP $f for $M/$T"; exit 6; }
done
echo "===== $M / $T"
echo -n "  MULTISET DISTANCE pristine: "
bash "$HERE/msdist.sh" "$O/g.dump" "$O/p.dump" | sed -n 's/^MULTISET DISTANCE.*: //p'
echo -n "  MULTISET DISTANCE patched : "
bash "$HERE/msdist.sh" "$O/g.dump" "$O/a.dump" | sed -n 's/^MULTISET DISTANCE.*: //p'
bash "$HERE/msmovers.sh" "$O/g.dump" "$O/p.dump" "$O/a.dump"
rm -rf "$O"
