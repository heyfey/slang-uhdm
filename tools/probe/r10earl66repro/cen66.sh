#!/usr/bin/env bash
# r10earl65 — run tscen66 on a database and NORMALISE the span fields so that
# golden (which carries VpiFile) and ours (which does not, RESUME §9) join.
# Only the FILE part of span=/tsspan= is dropped; line:col survives.
# MEASUREMENT ONLY.  usage: [R66_INST=1] cen66.sh <db.uhdm> > cells
set -u
CEN=${TSCEN66:?set TSCEN66 to the built tscen66}
"$CEN" "$1" | sed 's/\(ts\)\?span=[^ ]*:\([0-9]\+:[0-9]\+-[0-9]\+:[0-9]\+\)/\1span=\2/g'
