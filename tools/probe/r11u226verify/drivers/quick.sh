#!/bin/bash
# quick.sh <casedir>...: the law binary alone on each case in both views (a triage of whether a case is judge-equal at
# the base before its grid; the grid's own runs are grid.py's).  Fail-closed on $FENCED through case.sh.
source "$(dirname "$0")/env.sh" || exit 2
for c in "$@"; do
  for el in 0 1; do EL=$el bash "$(dirname "$0")/case.sh" "$c" q "$LAW"; done
done
