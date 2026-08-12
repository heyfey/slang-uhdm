#!/usr/bin/env bash
# r10uvm61repro/foldgrid.sh — for ONE arm directory, print, per SOURCE LINE,
# what each side put at that line: a sys_func_call (SYMBOLIC, unfolded) or a
# constant (FOLDED, with its value/size/const-type/typespec).
#
#   usage: foldgrid.sh <armdir> [lines...]        (no lines = every line that
#                                                  holds a sys_func_call on
#                                                  EITHER side)
#
# GUARDS:
#   * BOTH dumps are censused for BOTH shapes.  A line that is a constant on
#     one side and absent on the other prints ABSENT, never blank -- "census
#     BOTH sides before any missing-object claim".
#   * dumps are the arm's `sed 1d`-ed g.dump/o.dump; the raw .uhdm is never
#     read here.
#   * the dump repeats every object under back-reference edges; each (line,
#     shape) is reduced to a SET, so repetition cannot inflate a cell.
set -u
D=${1:?armdir}
G=$D/g.dump
O=$D/o.dump
for f in "$G" "$O"; do [ -s "$f" ] || { echo "FATAL: no/empty $f"; exit 3; }; done

# collect: line -> shape, per side
scan() {
  awk '
    /\\_sys_func_call: \(\$[a-z_0-9]*\), line:[0-9]+:[0-9]+/ {
      match($0, /\(\$[a-z_0-9]*\)/); fn=substr($0,RSTART+1,RLENGTH-2)
      match($0, /line:[0-9]+:[0-9]+, endln:[0-9]+:[0-9]+/); sp=substr($0,RSTART+5,RLENGTH-5)
      print sp "\tSYMBOLIC\t" fn; next
    }
    /\\_constant: , line:[0-9]+:[0-9]+/ {
      match($0, /line:[0-9]+:[0-9]+, endln:[0-9]+:[0-9]+/); sp=substr($0,RSTART+5,RLENGTH-5)
      cur=sp; dec=""; sz=""; val=""; ct=""; ts="-"
      for (i=0;i<14;i++) {
        if ((getline nx) <= 0) break
        if (nx ~ /\\_/ && nx !~ /vpiParent|vpiActual/) break
        if (nx ~ /\|vpiDecompile:/) { sub(/.*\|vpiDecompile:/,"",nx); dec=nx }
        else if (nx ~ /\|vpiSize:/)  { sub(/.*\|vpiSize:/,"",nx);  sz=nx }
        else if (nx ~ /\|vpiConstType:/) { sub(/.*\|vpiConstType:/,"",nx); ct=nx }
        else if (nx ~ /\|vpiTypespec:/)  { ts="TS" }
        else if (nx ~ /\|(UINT|INT|BIN|DEC|STRING|REAL):/) { sub(/.*\|/,"",nx); val=nx }
      }
      print cur "\tCONST\tval=" val " sz=" sz " ct=" ct " ts=" ts
    }
  ' "$1" | sort -u
}
scan "$G" > /tmp/.fg_g.$$
scan "$O" > /tmp/.fg_o.$$

shift || true
if [ $# -gt 0 ]; then LINES="$*"
else
  LINES=$( { grep -P '\tSYMBOLIC\t' /tmp/.fg_g.$$ /tmp/.fg_o.$$ | sed 's/.*://;' ; } >/dev/null 2>&1;
           cat /tmp/.fg_g.$$ /tmp/.fg_o.$$ | awk -F'\t' '$2=="SYMBOLIC"{split($1,a,":"); print a[1]}' | sort -un )
fi
printf '%-6s | %-46s | %-46s | %s\n' LINE GOLDEN OURS VERDICT
for l in $LINES; do
  g=$(awk -F'\t' -v L="^$l:" '$1 ~ L {print $2" "$3}' /tmp/.fg_g.$$ | paste -sd' ; ')
  o=$(awk -F'\t' -v L="^$l:" '$1 ~ L {print $2" "$3}' /tmp/.fg_o.$$ | paste -sd' ; ')
  [ -z "$g" ] && g="ABSENT"
  [ -z "$o" ] && o="ABSENT"
  v=SAME; [ "$g" != "$o" ] && v=DIFFER
  printf '%-6s | %-46s | %-46s | %s\n' "$l" "$g" "$o" "$v"
done
rm -f /tmp/.fg_g.$$ /tmp/.fg_o.$$
