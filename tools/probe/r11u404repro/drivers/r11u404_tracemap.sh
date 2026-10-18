#!/bin/bash
# usage: r11u404_tracemap.sh <trace dir>  -> "<db path> law:count ..." per trace file, fenced rows filtered out
# by the FENCED= line BEFORE any trace file is opened (the OUT line is read with head only after filtering
# the file list on the db path recorded in its name-independent first line is impossible, so the filter
# runs on the first line read by `head -1` of each file and drops the file when a fenced name matches).
eval "$(grep '^FENCED=' /tmp/wt_r11u404/tools/probe/r11u107repro/canaudit.sh)"
pat=$(echo $FENCED | sed 's/ /|/g')
for f in $1/*; do
  o=$(head -1 "$f" | awk '{print $2}')
  echo "$o" | grep -Eqw "$pat" && continue
  laws=$(tail -n +2 "$f" | awk '{print $1}' | sort | uniq -c | awk '{printf "%s:%s ",$2,$1}')
  echo "$o $laws"
done
