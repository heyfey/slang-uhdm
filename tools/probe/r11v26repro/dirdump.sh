#!/usr/bin/env bash
# v11u26 verifier — ORDER-BLIND DIRECTIONAL DUMP CENSUS for one grid arm.
# Normalises object ids and the workdir path out of the three uhdm-dumps
# (golden / pristine / patched), sorts them, and scores every line that the
# patch ADDED or REMOVED against GOLDEN's own multiset:
#   TO-GOLDEN   a line the patch ADDED that golden has
#   AWAY-NEW    a line the patch ADDED that golden does NOT have
#   AWAY-LOST   a line the patch REMOVED that golden HAS      <- the killer
#   DROP-WRONG  a line the patch REMOVED that golden does not have (good)
# A pure id renumbering scores 0 everywhere.
set -u
d=${1:?arm dir}
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
g=$(find "$d/gold" -name 'surelog.uhdm' | head -1)
norm() { sed -e 's/id:[0-9]*/id:#/g' -e "s#$d/##g" -e 's#/tmp/[^ ,]*##g' "$1" | sort; }
$UD "$g" > "$d/g.dump" 2>/dev/null
norm "$d/g.dump" > "$d/g.n"; norm "$d/pris.dump" > "$d/p.n"; norm "$d/pat.dump" > "$d/q.n"
comm -13 "$d/p.n" "$d/q.n" > "$d/added"
comm -23 "$d/p.n" "$d/q.n" > "$d/removed"
tg=$(comm -12 "$d/added"   "$d/g.n" | wc -l)
an=$(comm -23 "$d/added"   "$d/g.n" | wc -l)
al=$(comm -12 "$d/removed" "$d/g.n" | wc -l)
dw=$(comm -23 "$d/removed" "$d/g.n" | wc -l)
echo "$(basename $d) added=$(wc -l < $d/added) removed=$(wc -l < $d/removed) TO-GOLDEN=$tg AWAY-NEW=$an AWAY-LOST=$al DROP-WRONG=$dw"
