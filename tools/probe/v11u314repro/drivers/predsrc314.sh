#!/bin/bash
# v11u314 predsrc314.sh <out>: a source-text predictor of the pass's triggers over the two corpus source trees,
# run before reading the law sweep. The path list is built first and filtered by $FENCED (word boundary) before any
# file is opened; then each file is searched for the written shapes the nine laws key on:
#  W  an indexed part select whose width is package-qualified        ([+-]:\s*\w+::\w+)
#  T  a this.<name>[ path inside a select index                       (\[[^]=;]*this\.\w+\[)
#  S  a class-scope call as an index                                  (\[\s*\w+(#\(.*\))?::\w+\s*\()
#  O  an indexed part select whose base is an operation, select or system call ([^[]\[[^][;]*([-+*/%&|^<>]|\$\w+\(|\w\[)[^][;]*[+-]:)
#  M  a method call on a selected receiver inside an index            (\[\s*[\w.]+\[[^]]*\](\.\w+)*\.\w+\(\)?)
#  B  a named block inside a task or function body with a member-path select target (begin\s*:\s*\w+)
# Prints one line per (file, tag); fail-closed on $FENCED.
H=$(cd "$(dirname "$0")" && pwd); source "$H/env.sh" || exit 2
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "predsrc314: FENCED unset" >&2; exit 2; }
O=$1; T=$(mktemp -d /tmp/v11u314_pred.XXXX)
{ find "$SURELOG_ROOT/tests" "$SURELOG_ROOT/third_party/tests" "$UHDM2RTLIL_TESTS" -type f \( -name '*.sv' -o -name '*.v' -o -name '*.svh' -o -name '*.vh' -o -name '*.svi' -o -name '*.inc' \) 2>/dev/null; } > $T/all
grep -vwE "$(echo $FENCED | tr ' ' '|')" $T/all > $T/ok
echo "files listed $(wc -l < $T/all), after fence $(wc -l < $T/ok)" > $O
pat() { tr '\n' '\0' < $T/ok | xargs -0 grep -lP -- "$2" 2>/dev/null | sed "s#^#$1 #"; }
{ pat W '[+-]:\s*\w+::\w+'
  pat T '\[[^\]=;]*this\.\w+\['
  pat S '\[\s*\w+(#\([^)]*\))?::\w+\s*\('
  pat O '\w\[[^\[\];]*([-+*/%&|^<>]|\$\w+\(|\w\[)[^\[\];]*[+-]:'
  pat M '\[\s*[\w.]+\[[^\]]*\](\.\w+)*\.\w+\s*\('
} | sort >> $O
rm -rf $T
