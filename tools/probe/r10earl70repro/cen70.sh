#!/usr/bin/env bash
# r10earl70 — run tscen70 on a database and NORMALISE the span fields so that
# golden (which carries VpiFile) and ours (which does not, RESUME §9) join.
# Only the FILE part of span=/tsspan= is dropped; line:col survives.
# MEASUREMENT ONLY.  usage: [R66_INST=1] cen70.sh <db.uhdm> > cells
set -u
CEN=${TSCEN70:?set TSCEN70 to the built tscen70}
"$CEN" "$1" | sed 's/\(ts\)\?span=[^ ]*:\([0-9]\+:[0-9]\+-[0-9]\+:[0-9]\+\)/\1span=\2/g'
