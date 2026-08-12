#!/bin/bash
# r10uvm62repro/elgrid.sh — census, on BOTH sides, EVERY object that OWNS a
# `vpiEndLabel` slot in the UHDM model (class_defn, module_inst, interface_inst,
# program, package, named_begin, named_event, named_fork) and print, per object
# NAME, whether that side carries a vpiEndLabel and with what value.
#
#   usage: elgrid.sh <armdir>            (reads <armdir>/g.dump and <armdir>/o.dump)
#
# WHY IT IS BUILT THIS WAY — the three traps this campaign has already paid for:
#
#  1. CENSUS BOTH SIDES FOR BOTH SHAPES.  A cell that exists on one side only
#     must print ABSENT, never blank: `grep vpiEndLabel` alone cannot tell
#     "golden has no label here" from "we do not emit the object at all".  So
#     the key set is the UNION of both sides' objects and every cell prints one
#     of  LABEL:<v> / NOLABEL / NO-OBJECT.
#
#  2. THE DUMP REPEATS EVERY OBJECT under each back-reference edge (vpiParent,
#     vpiActual, vpiClassDefn, ...).  A raw grep double-counts.  Only a
#     DEFINITIONAL occurrence — one whose OWN indentation block also carries the
#     object's field lines — can answer "does this object have an end label".
#     We therefore walk the indentation tree: an object line at indent I owns
#     exactly the `|field` lines at indent I+2 that follow it before the next
#     line at indent <= I.
#
#  3. SPANS ARE NOT KEYS.  uvm-1.2 is hundreds of files and the dump prints no
#     file per object, so `line:32:9` is ambiguous across the design.  The key
#     is TYPE + NAME as the dump prints them.
#
# GUARD: an armdir whose dumps hold ZERO end-label-owning objects is a hard
# error — an empty census reads exactly like a perfect match.
set -u
D=${1:?armdir}
for f in g.dump o.dump; do
  [ -s "$D/$f" ] || { echo "FATAL: missing or empty $D/$f"; exit 3; }
done

side() {  # $1 = dumpfile -> "TYPE|NAME<TAB>LABEL|NOLABEL:<value>"
  awk '
    # BEGIN IS LOAD-BEARING.  Without it `nopen` starts as the EMPTY STRING, so
    # the FIRST frame is stored under the subscript "" and `nopen++` then jumps
    # straight to 1 — index 0 is never written, the first end-label-owning
    # object in the dump is DROPPED from the census, and a bogus empty-key row
    # appears in its place.  Found by auditing the instrument against its own
    # output (a "NO-OBJECT/NO-OBJECT" row that named nothing), not by theory.
    BEGIN { nopen = 0 }
    match($0, /\\_/) {
      ind = RSTART - 1
      rest = substr($0, RSTART + 2)
      ty = rest; sub(/:.*/, "", ty)
      nm = ""
      if (match(rest, /\(([^)]*)\)/)) nm = substr(rest, RSTART + 1, RLENGTH - 2)
      # A STACK, POPPED — not a flat array scanned linearly.  The flat form was
      # O(objects^2) and did not finish a 1.1M-line uvm dump in two minutes; the
      # corpus census is the whole point of this instrument, so the frame set is
      # a real stack: every object line pops (and RECORDS) each frame whose
      # indent is >= this one, then pushes if the type owns an end label.
      while (nopen > 0 && openind[nopen-1] >= ind) { record(--nopen) }
      if (ty ~ /^(class_defn|module_inst|interface_inst|program|package|named_begin|named_event|named_fork)$/) {
        openind[nopen] = ind; openkey[nopen] = ty "|" nm
        openlbl[nopen] = ""; nopen++
      }
      next
    }
    match($0, /\|vpiEndLabel:/) {
      ind = RSTART - 1
      v = substr($0, RSTART + 13)
      # A FIELD LINE POPS TOO.  `vpiEndLabel` is printed AFTER the object'"'"'s
      # children, and children are only popped by the next OBJECT line — so at
      # this point the stack top is very often a deeper child frame, not the
      # owner.  Popping on the field line is what makes the top the owner.
      # (Caught by the instrument disagreeing with its own earlier run: three
      # labels golden certainly has — A_lbl, X_lbl, N_out — turned into
      # ORPHAN-ENDLABEL.  The orphan counter is why it was visible at all.)
      while (nopen > 0 && openind[nopen-1] >= ind) { record(--nopen) }
      if (nopen > 0 && openind[nopen-1] == ind - 2) openlbl[nopen-1] = v
      else orphan++
      next
    }
    END {
      while (nopen > 0) record(--nopen)
      for (k in res) print k "\t" res[k]
      if (orphan > 0) print "ORPHAN-ENDLABEL|" orphan "\tNOLABEL"
    }
    function record(i,   k) {
      k = openkey[i]
      # LABEL WINS over NOLABEL for a repeated key: the dump prints an object
      # once definitionally and again under every back-reference edge, and the
      # back-reference print carries no field lines.  Recording NOLABEL last
      # would erase a real label.
      if (openlbl[i] != "") res[k] = "LABEL:" openlbl[i]
      else if (!(k in res)) res[k] = "NOLABEL"
    }
  ' "$1" | LC_ALL=C sort
}

side "$D/g.dump" > "$D/.el.g"
side "$D/o.dump" > "$D/.el.o"
ng=$(wc -l < "$D/.el.g"); no=$(wc -l < "$D/.el.o")
echo "end-label-owning objects: golden=$ng ours=$no"
if [ "$ng" -eq 0 ] && [ "$no" -eq 0 ]; then
  echo "REFUSING TO REPORT: census found NO end-label-owning object on either side"
  exit 5
fi

printf "%-16s %-34s %-28s %-28s %s\n" TYPE NAME GOLDEN OURS VERDICT
diffc=0; total=0
LC_ALL=C join -t $'\t' -a1 -a2 -e NO-OBJECT -o 0,1.2,2.2 "$D/.el.g" "$D/.el.o" |
while IFS=$'\t' read -r k g o; do
  ty=${k%%|*}; nm=${k#*|}
  [ "$nm" = "" ] && nm='<anon>'
  if [ "$g" = "$o" ]; then v=ok; else v="**DIFF**"; fi
  printf "%-16s %-34s %-28s %-28s %s\n" "$ty" "$nm" "$g" "$o" "$v"
done

# counted in a separate pass because the loop above runs in a subshell
tot=$(LC_ALL=C join -t $'\t' -a1 -a2 -e NO-OBJECT -o 0,1.2,2.2 "$D/.el.g" "$D/.el.o" | wc -l)
dif=$(LC_ALL=C join -t $'\t' -a1 -a2 -e NO-OBJECT -o 0,1.2,2.2 "$D/.el.g" "$D/.el.o" |
      awk -F'\t' '$2!=$3' | wc -l)
echo "-- objects=$tot  DIFFERING CELLS=$dif"
