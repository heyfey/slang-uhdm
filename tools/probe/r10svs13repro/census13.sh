#!/usr/bin/env bash
# r10svs13 CARRIER CENSUS — an UPPER BOUND, and it says so.
#
#   usage: ./census13.sh            # both corpora
#
# WHAT IT PREDICTS.  § progPortIfaceArrayUnowned13 can only move a database that
# contains BOTH
#   (a) a `program` declaration WITH A PORT LIST, and
#   (b) somewhere in the same test dir, an interface-ARRAY port declaration of
#       the form `<type>.<modport> <name> [` or `<type> <name> [`.
# Neither is sufficient — the producer also needs the port's CONNECTION to
# resolve to an `InstanceArray` symbol, the program to actually be INSTANTIATED
# (a program never reached leaves the def view alone), and slang to accept the
# file at all.  Three sufficient conditions are therefore omitted and this is a
# NECESSARY-CONDITION filter, i.e. an UPPER BOUND on the mover set.  THE BYTE
# VERIFIER IS THE AUTHORITY; this is run FIRST only so its answer is recorded
# before the verifier's is known.
#
# TRAPS ENCODED:
#   * `program` also appears in comments, in `endprogram`, and inside strings;
#     the (a) test is deliberately loose in that direction.
#   * a `program` with NO port list cannot carry an iface port at all, so the (a)
#     test requires a `(` on the same line — which in turn MISSES a port list
#     opened on the next line.  Stated, not hidden: this filter can undercount
#     in exactly that one way, and the verifier is what closes it.
#   * the (b) test is run over the WHOLE test dir, not just the program's own
#     file, because a corpus test compiles a filelist.
set -u
ROOT_SL=$HOME/git-repos/Surelog
ROOT_U2R=$HOME/git-repos/uhdm2rtlil/test
hit() { # hit <dir>
    local d=$1
    grep -rlE '^[[:space:]]*program[[:space:]]+[A-Za-z_][A-Za-z_0-9]*[[:space:]]*\(' \
        "$d" --include='*.sv' --include='*.v' --include='*.svh' -s >/dev/null 2>&1 || return 1
    grep -rlE '[A-Za-z_][A-Za-z_0-9]*(\.[A-Za-z_][A-Za-z_0-9]*)?[[:space:]]+[A-Za-z_][A-Za-z_0-9]*[[:space:]]*\[[^]]*\][[:space:]]*[,)]' \
        "$d" --include='*.sv' --include='*.v' --include='*.svh' -s >/dev/null 2>&1 || return 1
    return 0
}
echo "== surelog corpus (one dir per <Name>.sl)"
n=0; t=0
for f in "$ROOT_SL"/tests/*/*.sl "$ROOT_SL"/third_party/tests/*/*.sl; do
    [ -f "$f" ] || continue
    d=$(dirname "$f"); t=$((t+1))
    if hit "$d"; then echo "   $(basename "$d")"; n=$((n+1)); fi
done
echo "   -> $n of $t test dirs"
echo "== uhdm2rtlil corpus"
m=0; u=0
for d in "$ROOT_U2R"/*/; do
    [ -d "$d" ] || continue
    u=$((u+1))
    if hit "$d"; then echo "   $(basename "$d")"; m=$((m+1)); fi
done
echo "   -> $m of $u test dirs"
echo "UPPER BOUND: $((n+m)) test dirs across both corpora."
