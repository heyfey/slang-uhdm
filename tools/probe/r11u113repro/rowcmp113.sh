#!/bin/bash
# rowcmp113.sh <sweep-workdir> <out-dir> <name>...: uhdm-cmp (LHS golden) of the named rows'
# databases already written by a sweep (no database is re-written); one line per row-mode.
W=${1:?workdir}; O=${2:?out}; shift 2; mkdir -p "$O"
for n in "$@"; do
  for d in $(find "$W" -maxdepth 3 -type d -name "$n-*" | sort); do
    [ -f "$d/slang.uhdm" ] || { echo "$n ${d#$W/} NO-DB"; continue; }
    g=$(grep -o 'cache hit [^)]*' "$d/cmds.txt" | awk '{print $3}')/golden.uhdm
    k=$(echo "${d#$W/}" | tr '/' '_'); ~/git-repos/UHDM/build/bin/uhdm-cmp "$g" "$d/slang.uhdm" > "$O/$k.cmp" 2>&1
    echo "${d#$W/} lines=$(wc -l < "$O/$k.cmp") heads=$(grep -c '^LHS:' "$O/$k.cmp"; true) bin=$(grep -o '^slang: *[^ ]*' "$d/cmds.txt" | awk '{print $2}')"
  done
done
