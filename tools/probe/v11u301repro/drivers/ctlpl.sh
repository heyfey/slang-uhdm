#!/bin/bash
# v11u301 ctlpl.sh <out> <list file>...: byte controls, P and L in both views on every case dir listed (path lists are
# built with find and filtered by $FENCED before any file is opened; a fenced path is skipped here too).
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
for c in $(cat "$@"); do
  for n in $FENCED; do echo "$c" | grep -qw "$n" && continue 2; done
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
  done
done
