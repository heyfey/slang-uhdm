#!/bin/bash
# usage: rungrid.sh <griddir> <bin> [tag]   prints case verdict + golden/ours alias names
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
G=$1; BIN=$2; T=${3:-o}
for c in $(ls $G); do
  r=$(SLANG_UHDM=$BIN bash $HERE/case.sh $G/$c $G/$c/$T 2>&1 | sed 's/ out=.*//')
  ga=$(grep -o 'ref_typespec: ([^)]*\(alias_t\|g_int_t\|g_bit_t\))' $G/$c/$T/g.dump 2>/dev/null | sort -u | sed 's/ref_typespec: //' | tr '\n' ' ')
  oa=$(grep -o 'ref_typespec: ([^)]*\(alias_t\|g_int_t\|g_bit_t\))' $G/$c/$T/o.dump 2>/dev/null | sort -u | sed 's/ref_typespec: //' | tr '\n' ' ')
  printf "%-8s %-45s G:%s | O:%s\n" "$c" "$r" "$ga" "$oa"
done
