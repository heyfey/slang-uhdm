#!/usr/bin/env bash
# subset.sh <griddir> <arm...> — the ORDER-BLIND diff-line SUBSET check: every
# golden-vs-ours differing line the patched binary shows must already be in the
# pristine binary's set (NEW=0), which is the strongest statement of "moved
# only toward golden" a whole-dump census can make.  The dump's own header line
# names the output file and is normalised away.
set -u
G=$1; shift
T=$(mktemp -d /tmp/r11u14_subset.XXXXXX); trap 'rm -rf "$T"' EXIT
tot_new=0; tot_res=0
for a in "$@"; do
  for k in gold pris pat; do
    sed -e "s#$G##g" -e 's#^[^ ]*\.uhdm: #DUMPHDR: #' "$G/$a/$k.dump" | sort > "$T/$k"
  done
  diff "$T/gold" "$T/pris" | grep '^[<>]' | sort -u > "$T/dp"
  diff "$T/gold" "$T/pat"  | grep '^[<>]' | sort -u > "$T/dq"
  new=$(comm -13 "$T/dp" "$T/dq" | grep -c . ; true)
  res=$(comm -23 "$T/dp" "$T/dq" | grep -c . ; true)
  tot_new=$((tot_new+new)); tot_res=$((tot_res+res))
  echo "$a NEW-DIFF-LINES=$new RESOLVED=$res"
  [ "$new" -gt 0 ] && comm -13 "$T/dp" "$T/dq" | head -5 | cut -c1-160
done
echo "TOTALS NEW=$tot_new RESOLVED=$tot_res"
