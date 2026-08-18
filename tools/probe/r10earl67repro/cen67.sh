#!/usr/bin/env bash
# r10earl67 — run tscen67 on a database and NORMALISE the span fields so that
# golden (which carries VpiFile) and ours (which does not, RESUME §9) join.
# Only the FILE part of span=/tsspan= is dropped; line:col survives.
# MEASUREMENT ONLY.  usage: [R66_INST=1] cen67.sh <db.uhdm> > cells
set -u
CEN=${TSCEN67:?set TSCEN67 to the built tscen67}
"$CEN" "$1" | sed 's/\(ts\)\?span=[^ ]*:\([0-9]\+:[0-9]\+-[0-9]\+:[0-9]\+\)/\1span=\2/g'
