#!/usr/bin/env bash
# r10oth7 — the class_typespec FIELD CENSUS, per side, counting OBJECTS.
#
#   usage: ctcount.sh <g.dump> <o.dump>
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# Both dumps MUST already have uhdm-dump's FIRST LINE (the database path)
# stripped -- ctdump.sh does that.  This script re-asserts it and refuses
# otherwise, because a stray line 1 shifts every line number it reports.
#
# It counts, at indent 0 inside the trailing `\_weaklyReferenced:` block (the
# only place uhdm-dump prints a typespec's OWN fields; every other appearance is
# a vpiActual back-reference that prints the header line alone):
#   * class_typespec objects total
#   * how many carry vpiName
#   * how many carry vpiClassDefn
#   * the two half-missing populations this pass is about:
#       NAME-but-no-DEFN   (the SVSwitch head: golden links, we do not)
#       DEFN-but-no-NAME   (the mirror half: golden names, we do not)
#
# SANITY CHECK (a broken counter reports a closed head): name+defn+nameonly+
# defnonly+neither must equal the object total on each side, and the script
# prints FAIL and exits 4 if it does not.
set -u
G=${1:?g.dump}
O=${2:?o.dump}
for f in "$G" "$O"; do
  [ -f "$f" ] || { echo "FATAL: missing $f"; exit 9; }
  # THE GUARD'S FIRST DRAFT DID NOT BITE: it matched '\.uhdm$', but uhdm-dump's
  # line 1 is `<path>.uhdm: Restored design Pre-Elab:` -- the path is NOT at the
  # end of the line, so a raw dump sailed straight through.  Negative control is
  # now run: a raw dump exits 8.
  if head -1 "$f" | grep -qE '\.uhdm:|Restored design'; then
    echo "REFUSED: $f still has uhdm-dump's database-path line 1 (sed 1d it)"
    exit 8
  fi
done

one() {
  awk '
    /^\\_weaklyReferenced:/ { inw=1; next }
    !inw { next }
    /^\\_class_typespec:/ {
      if (cur) emit()
      cur=1; nm=0; cd=0; next
    }
    /^\\_/ { if (cur) { emit(); cur=0 } ; next }
    cur && /^  \|vpiName:/ { nm=1 ; next }
    cur && /^  \|vpiClassDefn:/ { cd=1 ; next }
    function emit() {
      tot++
      if (nm) hasn++
      if (cd) hasd++
      if (nm && cd) both++
      if (nm && !cd) nonly++
      if (!nm && cd) donly++
      if (!nm && !cd) neither++
    }
    END {
      if (cur) emit()
      printf "objects=%d withName=%d withClassDefn=%d both=%d NAME_ONLY=%d DEFN_ONLY=%d neither=%d\n", tot, hasn, hasd, both, nonly, donly, neither
      if (both+nonly+donly+neither != tot) { printf "SELFCHECK FAIL: partition %d != total %d\n", both+nonly+donly+neither, tot; exit 4 }
    }
  ' "$1"
}

# EXIT PROPAGATION, and it was BROKEN in the first draft: `echo "... $(one x)"
# || exit 4` takes the status of ECHO, never of `one`, so the partition
# SELFCHECK printed its failure and the script still exited 0.  Caught by running
# the check's own negative control (a deliberately corrupted bucket).
gl=$(one "$G"); rcg=$?
ol=$(one "$O"); rco=$?
echo "LHS golden(Surelog): $gl"
echo "RHS ours           : $ol"
[ "$rcg" -eq 0 ] && [ "$rco" -eq 0 ] || { echo "PARTITION SELFCHECK FAILED"; exit 4; }
echo "-- named-by-class breakdown (objects at indent 0 in weaklyReferenced)"
for side in G O; do
  f=$G; lbl="golden(LHS)"; [ "$side" = O ] && { f=$O; lbl="ours(RHS)  "; }
  awk -v lbl="$lbl" '
    /^\\_weaklyReferenced:/ { inw=1; next }
    !inw { next }
    # A RUN of consecutive class_typespec headers is normal in this listing, so
    # a new header must FLUSH the previous object before resetting -- forgetting
    # that under-counted golden mailbox 10 -> 2 on the first draft of this
    # script, which is exactly the "broken counter reports a closed head" trap.
    /^\\_class_typespec:/ { if (cur) print lbl"  name="nm"  defn="cd
                            cur=1; nm="<unnamed>"; cd="-"; next }
    /^\\_/ { if (cur) { print lbl"  name="nm"  defn="cd; cur=0 }; next }
    cur && /^  \|vpiName:/ { nm=substr($0, 12); next }
    cur && /^  \|vpiClassDefn:/ { getline l; if (match(l, /\(([^)]*)\)/)) cd=substr(l, RSTART+1, RLENGTH-2); next }
    END { if (cur) print lbl"  name="nm"  defn="cd }
  ' "$f"
done | sort | uniq -c | sort -k3
