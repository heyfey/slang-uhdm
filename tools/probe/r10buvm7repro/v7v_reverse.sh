#!/usr/bin/env bash
# vbuvm7 — THE REVERSE CENSUS.  The prediction asks "where must we move?";
# this asks the adversarial question: "where did we collapse and golden did NOT?"
# For every (test,mode) with a database, joins on line:col-span and reports
#   WRONGCOLLAPSE  ours WIDEREF at a position golden calls PATH/SEL/PLAIN
#   MISSED         golden WIDEREF/WIDESEL at a position we call PATH/SEL
# A row with no golden prints NOGOLD and is COUNTED.
set -u
W=${1:?workdir}; TAG=${2:?tag}
CEN=/tmp/vbuvm7_cen
wc=0; ms=0; ng=0; nd=0; rows=0
for d in "$W"/*/*/; do
  mode=$(basename "$(dirname "$d")"); nm=$(basename "$d"); nm=${nm%-*}
  O=$d/slang.uhdm; C=$d/cmds.txt
  [ -f "$O" ] || { nd=$((nd+1)); continue; }
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" 2>/dev/null | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then echo "NOGOLD $TAG/$mode/$nm"; ng=$((ng+1)); continue; fi
  rows=$((rows+1))
  "$CEN" "$G" G 2>/dev/null | awk '/^INCDEC/{print $3, $5}' | sort -u > /tmp/vbuvm7_rev_g.$$
  "$CEN" "$O" O 2>/dev/null | awk '/^INCDEC/{print $3, $5}' | sort -u > /tmp/vbuvm7_rev_o.$$
  # ours WIDEREF at a position golden does not call WIDEREF
  while read -r pos cls; do
    gcls=$(awk -v p="$pos" '$1==p{print $2}' /tmp/vbuvm7_rev_g.$$ | head -1)
    [ -z "$gcls" ] && continue
    if [ "$cls" = WIDEREF ] && [ "$gcls" != WIDEREF ]; then
      echo "WRONGCOLLAPSE $TAG/$mode/$nm $pos ours=WIDEREF golden=$gcls"; wc=$((wc+1))
    fi
  done < /tmp/vbuvm7_rev_o.$$
  while read -r pos gcls; do
    ocls=$(awk -v p="$pos" '$1==p{print $2}' /tmp/vbuvm7_rev_o.$$ | head -1)
    [ -z "$ocls" ] && continue
    case "$gcls" in WIDEREF|WIDESEL)
      [ "$ocls" != "$gcls" ] && { echo "MISSED $TAG/$mode/$nm $pos golden=$gcls ours=$ocls"; ms=$((ms+1)); } ;;
    esac
  done < /tmp/vbuvm7_rev_g.$$
  rm -f /tmp/vbuvm7_rev_g.$$ /tmp/vbuvm7_rev_o.$$
done
echo "-- $TAG rows=$rows WRONGCOLLAPSE=$wc MISSED=$ms NOGOLD=$ng NO_DB=$nd"
