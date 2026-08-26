#!/bin/bash
# r10uvm159 — WHOLE-DUMP, PATH-NORMALISED, ORDER-BLIND diff of one moved
# database (pristine vs patched).  MEASUREMENT ONLY.
#
# Dump paths embed the workdir, so both sides are sed'd back to a fixed token
# before the diff; the dumps are SORTED so a pure ordering flip (Scoreboard's
# vpiTaskFunc coin) reads as zero lines and only real content shows.
#
#   usage: dumpdiff159.sh <pristine.uhdm> <patched.uhdm> <outdir> <tag>
set -u
A=${1:?pristine}; B=${2:?patched}; O=${3:?outdir}; T=${4:?tag}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
mkdir -p "$O"
"$DUMP" "$A" | sed 's#/tmp/[A-Za-z0-9_]*/#WD/#g' > "$O/$T.pris.dump"
"$DUMP" "$B" | sed 's#/tmp/[A-Za-z0-9_]*/#WD/#g' > "$O/$T.pat.dump"
echo "$T raw-lines pris=$(wc -l < "$O/$T.pris.dump") pat=$(wc -l < "$O/$T.pat.dump")"
sort "$O/$T.pris.dump" > "$O/$T.pris.sorted"
sort "$O/$T.pat.dump"  > "$O/$T.pat.sorted"
diff "$O/$T.pris.sorted" "$O/$T.pat.sorted" > "$O/$T.orderblind.diff"
echo "$T order-blind diff lines = $(wc -l < "$O/$T.orderblind.diff")"
