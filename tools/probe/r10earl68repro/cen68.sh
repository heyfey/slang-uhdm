#!/usr/bin/env bash
# r10earl68 — run tscen68 on a database and NORMALISE the span fields so that
# golden (which carries VpiFile) and ours (which does not, RESUME §9) join.
# Only the FILE part of span=/tsspan= is dropped; line:col survives.
# MEASUREMENT ONLY.  usage: [R66_INST=1] cen67.sh <db.uhdm> > cells
set -u
CEN=${TSCEN68:?set TSCEN68 to the built tscen68}
"$CEN" "$1" | sed 's/\(ts\)\?span=[^ ]*:\([0-9]\+:[0-9]\+-[0-9]\+:[0-9]\+\)/\1span=\2/g'
