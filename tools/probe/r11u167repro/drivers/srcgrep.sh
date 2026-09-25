#!/bin/bash
# srcgrep.sh <regex>: a PCRE grep over both corpora's test sources (.sv/.v/.svh) listing matching test
# dirs.  FAIL-CLOSED on $FENCED: refuses to run without the four names and drops every path
# holding a fenced name before anything is read.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "srcgrep.sh: export FENCED (four names) first" >&2; exit 1; }
FX=$(echo $FENCED | tr ' ' '|')
for root in $SURELOG_ROOT/tests $SURELOG_ROOT/third_party/tests $UHDM2RTLIL_TESTS; do
  find $root -type f \( -name '*.sv' -o -name '*.v' -o -name '*.svh' \) | grep -Pv "(^|/)($FX)(/|\.|$)" |
    xargs -r grep -lP "$1" 2>/dev/null
done
