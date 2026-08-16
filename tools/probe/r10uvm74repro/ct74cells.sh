#!/usr/bin/env bash
# r10uvm74 — PER-CELL table for an arm workdir.  A "cell" here is an INDEXED
# HIER_PATH STEP, named by the written component text (`sq[i]`, `m.lq[i]`,
# `cq[0]`), so the table prints, per side:
#
#   KIND / SPAN / vpiName / vpiFullName / the KIND of the vpiIndex child
#
# and nothing is collapsed: a within-side disagreement across prints shows as
# `a|b`.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: ct74cells.sh <armwd> <celltext> [<celltext> ...]
#
# GUARDS (each an ops trap this campaign has paid for):
#   * a cell text found in NEITHER dump prints UNKNOWN-CELL and is COUNTED --
#     a driver that matches nothing must never read as agreement.
#   * the INDEX-CHILD kind is printed alongside the object kind, because a
#     bit_select with NO index child is the exact defect a kind-only table
#     reads as green.
#   * the SPAN is printed, because this law's whole visible effect on the
#     element is that golden's span STOPS AT THE BASE NAME and ours ran
#     through the `]`.
set -u
D=${1:?arm workdir}
shift
[ -s "$D/g.dump" ] && [ -s "$D/o.dump" ] || { echo "FATAL: no dumps in $D"; exit 3; }
printf '%-18s %-44s %-44s %s\n' CELL 'LHS golden (kind span name/full idx)' 'RHS ours' VERDICT
unk=0; agree=0; dis=0
for c in "$@"; do
  seen=0
  for side in g o; do
    f=$D/$side.dump
    # every print of an object whose decompiled text is exactly this cell
    # LITERAL matching, not regex: a cell text CONTAINS `[` and `]`, and every
    # attempt to pass it through a regex here turned them into a character
    # class and made every cell read UNKNOWN-CELL -- i.e. the driver silently
    # measured nothing.  index() cannot do that.
    r=$(awk -v c="$c" '
      {
        line=$0
        lit="(" c "), line:"
        if (index(line, "\\_") && index(line, lit)) {
          k=line; sub(/^ *\\_/,"",k); sub(/:.*/,"",k)
          sp=line; sub(/.*, line:/,"",sp); sub(/, endln:/,"-",sp)
          # measure this print block: fields at indent+2
          base=match(line,/[^ ]/)-1
          nm=""; fu=""; ix=""; fld=""
          while ((getline nx) > 0) {
            st=nx; sub(/^ */,"",st)
            ind=match(nx,/[^ ]/)-1
            if (ind <= base && st ~ /^\\_/) break
            if (ind < base) break
            if (ind == base+2 && st ~ /^\|/) {
              fld=st; sub(/^\|/,"",fld); sub(/:.*/,"",fld)
              if (fld=="vpiName")     { v=st; sub(/^\|vpiName:/,"",v); nm=v }
              if (fld=="vpiFullName") { v=st; sub(/^\|vpiFullName:/,"",v); fu=v }
            }
            else if (ind == base+2 && st ~ /^\\_/) {
              if (fld=="vpiIndex") { v=st; sub(/^\\_/,"",v); sub(/:.*/,"",v); ix=v }
            }
          }
          if (fu=="") fu=nm
          if (ix=="") ix="NOINDEX"
          print k" "sp" "nm"/"fu" "ix
        }
      }' "$f" | sort -u | paste -sd'|')
    [ -n "$r" ] && seen=1
    if [ "$side" = g ]; then gv=$r; else ov=$r; fi
  done
  if [ "$seen" -eq 0 ]; then
    printf '%-18s %-44s %-44s %s\n' "$c" - - UNKNOWN-CELL; unk=$((unk+1)); continue
  fi
  v=AGREE; [ "$gv" = "$ov" ] || v=DISAGREE
  [ "$v" = AGREE ] && agree=$((agree+1)) || dis=$((dis+1))
  printf '%-18s %-44s %-44s %s\n' "$c" "${gv:--}" "${ov:--}" "$v"
done
echo "-- cells: agree=$agree DISAGREE=$dis UNKNOWN-CELL=$unk"
