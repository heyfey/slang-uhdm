#!/usr/bin/env bash
# r10uvm167repro/attrib167.sh — ORDER-BLIND attribution of one byte mover.
#
#   attrib167.sh <pristine wd> <patched wd> <mode/rowdir>
#
# `default/Scoreboard` is a ~50/50 COIN (RESUME §9: the svunit_pkg vpiTaskFunc
# list order flips per invocation, ~92 dump lines), so a mover may NOT be
# attributed by a raw diff.  Both databases are dumped, the WORKDIR PATH is
# normalised away (dump paths embed it), both sides are SORTED, and the
# difference is then read line by line: every line must belong to the law.
set -u
P=${1:?pristine wd}; Q=${2:?patched wd}; R=${3:?mode/rowdir}
D=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
T=$(mktemp -d /tmp/r10uvm167_attr.XXXXXX) || exit 1
"$D" "$P/$R/slang.uhdm" 2>/dev/null | sed "s#$P##g;s#$Q##g" | sort > "$T/a"
"$D" "$Q/$R/slang.uhdm" 2>/dev/null | sed "s#$P##g;s#$Q##g" | sort > "$T/b"
echo "== $R  pristine=$(wc -l < "$T/a") patched=$(wc -l < "$T/b") lines"
diff "$T/a" "$T/b" > "$T/d"; echo "== order-blind differing lines: $(grep -c '^[<>]' "$T/d" || true)"
grep '^[<>]' "$T/d" | sed 's/[0-9]\+/N/g' | sort | uniq -c | sort -rn
rm -rf "$T"
