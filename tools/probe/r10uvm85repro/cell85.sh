#!/usr/bin/env bash
# r10uvm85 — PER-CELL dump comparator.  MEASUREMENT-ONLY.
#
#   cell85.sh <arm85-workdir> [pris|pat] [line-lo] [line-hi]
#
# The uhdm-dump tree prints an object once per REFERENCE, so a raw `diff` of two
# dumps cannot be read cell by cell.  This reduces each dump to the SET of
# object headers — `kind|name|line:col-endline:endcol` — bucketed by SOURCE
# LINE, and prints per line the objects only GOLDEN has and the objects only
# OURS has.  IDs and vpiParent back-references are dropped (not comparable
# across producers).  A source line with no output is a cell whose object SETS
# agree; it is NOT a claim about fields the dump does not print.
set -u
D=${1:?arm workdir}
B=${2:-pris}
LO=${3:-0}
HI=${4:-999999}
A=$(mktemp /tmp/r10uvm85_cell_awk.XXXXXX)
cat > "$A" <<'AWK'
{
  if (match($0, /^[|\\_ ]*[a-z_0-9]+: /) == 0) next
  hdr = $0
  sub(/^[|\\_ ]*/, "", hdr)
  ci = index(hdr, ":")
  kind = substr(hdr, 1, ci-1)
  rest = substr(hdr, ci+2)
  if (match(rest, /line:[0-9]+:[0-9]+, endln:[0-9]+:[0-9]+/) == 0) next
  pre = substr(rest, 1, RSTART)
  nm = ""
  if (match(pre, /\(([^)]*)\)/)) nm = substr(pre, RSTART+1, RLENGTH-2)
  match(rest, /line:[0-9]+:[0-9]+, endln:[0-9]+:[0-9]+/)
  sp = substr(rest, RSTART+5, RLENGTH-5)
  sub(/, endln:/, "-", sp)
  split(sp, a, ":")
  print a[1] " " kind "|" nm "|" sp
}
AWK
G=$(mktemp /tmp/r10uvm85_cellg.XXXXXX); R=$(mktemp /tmp/r10uvm85_cellr.XXXXXX)
awk -f "$A" "$D/g.dump"  | sort -u > "$G"
awk -f "$A" "$D/$B.dump" | sort -u > "$R"
GL=$(mktemp /tmp/r10uvm85_clg.XXXXXX); RL=$(mktemp /tmp/r10uvm85_clr.XXXXXX)
diffc=0; samec=0
for L in $(cut -d' ' -f1 "$G" "$R" | sort -n -u); do
  [ "$L" -ge "$LO" ] && [ "$L" -le "$HI" ] || continue
  awk -v l="$L" '$1==l' "$G" | cut -d' ' -f2- | sort > "$GL"
  awk -v l="$L" '$1==l' "$R" | cut -d' ' -f2- | sort > "$RL"
  if cmp -s "$GL" "$RL"; then samec=$((samec+1)); continue; fi
  diffc=$((diffc+1))
  echo "== LINE $L"
  comm -23 "$GL" "$RL" | sed 's/^/  GOLDEN-ONLY  /'
  comm -13 "$GL" "$RL" | sed 's/^/  OURS-ONLY    /'
done
echo "-- $D [$B]  lines_AGREE=$samec  lines_DIFFER=$diffc"
rm -f "$A" "$G" "$R" "$GL" "$RL"
