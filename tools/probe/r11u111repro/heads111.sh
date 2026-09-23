#!/bin/bash
# heads111.sh <out-root> <tag>: per arm, the first object line of the LHS (golden) and RHS (ours) head.
O=${1:?out}; T=${2:?tag}
for c in $(find "$O" -name "$T.cmp" | sort); do
  a=${c#$O/}; a=${a%/$T.cmp}
  n=$(wc -l < "$c")
  L=$(awk '/^LHS:/{f=1; if ($0 ~ /<null>/){print "<null>"; exit}; next} f && /^[a-z_]+: /{print; exit}' "$c")
  R=$(awk '/^RHS:/{f=1; if ($0 ~ /<null>/){print "<null>"; exit}; next} f && /^[a-z_]+: /{print; exit}' "$c")
  echo "$a | $n | L: $L | R: $R"
done
