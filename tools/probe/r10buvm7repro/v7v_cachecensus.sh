#!/usr/bin/env bash
# vbuvm7 — census over EVERY cached golden database.  Totals only; a database
# that fails to restore is COUNTED (RESTORE_FAIL), never silently skipped.
set -u
out=${1:?out}
: > "$out"
n=0; fail=0
while read -r g; do
  /tmp/vbuvm7_cen "$g" G 2>/dev/null | grep -E '^(TOTALS|RESTORE_FAIL)' >> "$out"
  n=$((n+1))
done < <(find "$HOME/.cache/slang-uhdm-goldens" -name golden.uhdm | sort)
echo "databases_read=$n" >> "$out"
awk '/^TOTALS/{for(i=3;i<=NF;i++){split($i,a,"=");s[a[1]]+=a[2]}} /^RESTORE_FAIL/{rf++} END{printf "CACHE_CENSUS incdec=%d PLAIN=%d SEL=%d PATH=%d WIDEREF=%d WIDESEL=%d OTHER=%d RESTORE_FAIL=%d\n",s["incdec"],s["PLAIN"],s["SEL"],s["PATH"],s["WIDEREF"],s["WIDESEL"],s["OTHER"],rf+0}' "$out" >> "$out"
tail -2 "$out"
