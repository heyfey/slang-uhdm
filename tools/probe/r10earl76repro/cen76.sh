#!/usr/bin/env bash
# r10earl76 — the CORPUS census driver: census one database with cscen76,
# normalise it with norm76.sh.  Earlgrey's uhdm-dump is >1 GB and is NEVER
# produced (RESUME §9); cscen76 reads the `.uhdm` directly.
#   usage: CSCEN76=<bin> cen76.sh <db.uhdm> <out-prefix>
set -u
CEN=${CSCEN76:?}
D=$(dirname "$0")
LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib "$CEN" "$1" > "$2.cen" 2>/dev/null
bash "$D/norm76.sh" "$2.cen" > "$2.n"
echo "$2 cells=$(wc -l < "$2.cen") deduped=$(wc -l < "$2.n")"
