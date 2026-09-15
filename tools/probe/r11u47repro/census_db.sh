#!/bin/bash
# r11u47 DB CENSUS — from PRISTINE databases only.  A database is a PREDICTED
# MOVER when it holds a struct/union typespec whose VpiName is also the name of
# a `type_parameter` in the same database: that is exactly the object
# § tpAnonAggParamTsNoStamp47 un-names (makeParamTs' aggregate clone for a
# parameter declared with a type parameter's anonymous aggregate).
# Usage: census_db.sh <sweep-workdir> [timeout-secs]
W=$1; TMO=${2:-60}
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
for d in "$W"/*/*/; do
  [ -f "$d/slang.uhdm" ] || continue
  m=$(basename "$(dirname "$d")"); n=$(basename "$d"); n=${n%-*}
  timeout "$TMO" "$D" "$d/slang.uhdm" > /tmp/r11u47_cd.$$ 2>/dev/null || { echo "$m/$n DUMP-FAIL"; continue; }
  # type parameter names in this database
  grep -o '^\s*\\_type_parameter: ([^)]*)' /tmp/r11u47_cd.$$ | sed 's/.*(\(.*\))/\1/' | sed 's/.*\.//' | sort -u > /tmp/r11u47_cn.$$
  [ -s /tmp/r11u47_cn.$$ ] || continue
  hits=$(grep -oE '\\_(struct|union)_typespec: \([^)]*\)' /tmp/r11u47_cd.$$ | sed 's/.*(\(.*\))/\1/' | sort | uniq -c | \
         awk 'NR==FNR{tp[$0]=1;next}{ $1=$1; nm=$0; sub(/^[0-9]+ /,"",nm); c=$1; if (nm in tp) print nm"="c }' /tmp/r11u47_cn.$$ - | tr '\n' ' ')
  [ -n "$hits" ] && echo "$m/$n PREDICT $hits"
done
rm -f /tmp/r11u47_cd.$$ /tmp/r11u47_cn.$$
