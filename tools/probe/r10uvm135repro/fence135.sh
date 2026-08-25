#!/usr/bin/env bash
# r10uvm135repro/fence135.sh — THE CORPUS FENCE, written from PRISTINE databases
# only.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
#   fence135.sh <sweep workdir> <ct135cen binary> <out.tsv>
#
# For every test directory in the sweep workdir it censuses BOTH sides with
# ct135cen and joins on what both producers can spell — the IMPLICIT NET's
# (module fullname, name) — then classifies each ONE-SIDED implicit net:
#
#   HIT     golden has the wire, we do NOT, and the NAME is one this database
#           writes in an ASSOCIATIVE-INDEX bracket (an AIDX row of ours carries
#           it).  These are the cells the pass must move.
#   OTHER   golden has the wire, we do not, and the name is NOT an AIDX name of
#           ours — another family's; these must NOT move.
#   MIRROR  WE have a wire golden does not.  A WIDENING; must stay 0 for AIDX
#           names.
#
# Row: <CLASS> <mode> <test-dir> <module> <name>
set -u
WD=${1:?sweep workdir}; CEN=${2:?ct135cen}; OUT=${3:?out.tsv}
: > "$OUT"
tot=0; skip=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    t=$(basename "$d")
    O="$d/slang.uhdm"
    C="$d/cmds.txt"
    G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G="$G/golden.uhdm"
    tot=$((tot+1))
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then skip=$((skip+1)); continue; fi
    "$CEN" "$G" G > /tmp/r10uvm135_fence.g.$$ 2>/dev/null
    "$CEN" "$O" O > /tmp/r10uvm135_fence.o.$$ 2>/dev/null
    awk -F'\t' -v mode="$mode" -v t="$t" '
      FILENAME==ARGV[1] && $2=="NET" && $4=="IMPL" { gn[$5 SUBSEP $7]=1 }
      FILENAME==ARGV[2] && $2=="NET" && $4=="IMPL" { on[$5 SUBSEP $7]=1 }
      FILENAME==ARGV[2] && $2=="AIDX"              { aidx[$9]=1 }
      END {
        for (k in gn) if (!(k in on)) {
          split(k, p, SUBSEP)
          print (p[2] in aidx ? "HIT" : "OTHER") "\t" mode "\t" t "\t" p[1] "\t" p[2]
        }
        for (k in on) if (!(k in gn)) {
          split(k, p, SUBSEP)
          print "MIRROR\t" mode "\t" t "\t" p[1] "\t" p[2] "\t" (p[2] in aidx ? "AIDXNAME" : "-")
        }
      }' /tmp/r10uvm135_fence.g.$$ /tmp/r10uvm135_fence.o.$$ >> "$OUT"
  done
done
rm -f /tmp/r10uvm135_fence.g.$$ /tmp/r10uvm135_fence.o.$$
echo "measured=$tot SKIP=$skip"
for c in HIT OTHER MIRROR; do echo "$c $(grep -c "^$c	" "$OUT"; true)"; done
echo "databases that MUST move: $(awk -F'\t' '$1=="HIT"{print $2"/"$3}' "$OUT" | sort -u | wc -l)"
