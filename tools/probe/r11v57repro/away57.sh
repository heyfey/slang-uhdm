#!/usr/bin/env bash
# r11v57 STRICT AWAY SCORER — the question the residue COUNT cannot answer.
#
# A count going down can still hide a NEW divergence: one cell fixed, another
# broken.  So this scores SET CONTAINMENT over the JUDGE-REACHABLE dump only
# (DEF + ELAB; the weaklyReferenced TAIL is unreachable to Compare and is
# excluded by construction, not by subtraction):
#
#   NEW-OURS   ours-only lines under the LAW that were NOT ours-only at base
#   LOST-GOLD  golden-only lines under the LAW that were NOT golden-only at base
#
# Both must be 0 for "MOVED-WRONG 0 / AWAY 0".  A falling residue with
# NEW-OURS > 0 is an arm that moved sideways and must be read cell by cell.
#
#   usage: away57.sh <griddir> [<arm> ...]
set -u
G=${1:?griddir}; shift
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
ARMS=${*:-$(ls -d $G/*/ | xargs -n1 basename | sort -V)}
 jr() { # judge-reachable: everything before the weaklyReferenced tail.
       # The dump's own header names the DATABASE FILE, which differs by tag;
       # normalising it is what stops every arm reporting one phantom mover.
  awk '/weaklyReferenced:/{f=1} !f' "$1" \
    | sed -e "s#$2/##g" -e 's#^ours\.[a-z]*\.uhdm:#DB:#' | sort
}
printf "%-18s %7s %7s %7s %7s  %-9s %-9s %s\n" ARM b_g b_o l_g l_o NEW-OURS LOST-GOLD VERDICT
for a in $ARMS; do
  d=$G/$a; g=$d/slpp_all/surelog.uhdm
  [ -f "$g" ] || { printf "%-18s %7s %7s %7s %7s  %-9s %-9s %s\n" "$a" - - - - - - NO-GOLDEN; continue; }
  [ -f "$d/ours.base.uhdm" ] && [ -f "$d/ours.${LAWTAG:-law}.uhdm" ] || {
    printf "%-18s %7s %7s %7s %7s  %-9s %-9s %s\n" "$a" - - - - - - NO-DATABASE; continue; }
  $DUMP "$g" 2>/dev/null > /tmp/.aw.gr.$$; jr /tmp/.aw.gr.$$ "$d" > /tmp/.aw.g.$$
  for t in base ${LAWTAG:-law}; do
    $DUMP "$d/ours.$t.uhdm" 2>/dev/null > /tmp/.aw.or.$$; jr /tmp/.aw.or.$$ "$d" > /tmp/.aw.T$$
    diff /tmp/.aw.g.$$ /tmp/.aw.T$$ > /tmp/.aw.dT$$; true
    grep '^>' /tmp/.aw.dT$$ | sed 's/^> //' | sort > /tmp/.aw.o$t.$$
    grep '^<' /tmp/.aw.dT$$ | sed 's/^< //' | sort > /tmp/.aw.g$t.$$
  done
  bg=$(wc -l < /tmp/.aw.gbase.$$); bo=$(wc -l < /tmp/.aw.obase.$$)
  lg=$(wc -l < /tmp/.aw.g${LAWTAG:-law}.$$);  lo=$(wc -l < /tmp/.aw.o${LAWTAG:-law}.$$)
  no=$(comm -13 /tmp/.aw.obase.$$ /tmp/.aw.o${LAWTAG:-law}.$$ | grep -c .; true)
  ng=$(comm -13 /tmp/.aw.gbase.$$ /tmp/.aw.g${LAWTAG:-law}.$$ | grep -c .; true)
  v=CLEAN; [ "$no" != 0 ] && v=NEW-DIVERGENCE; [ "$ng" != 0 ] && v="$v/NEW-GOLDEN-ONLY"
  printf "%-18s %7s %7s %7s %7s  %-9s %-9s %s\n" "$a" $bg $bo $lg $lo $no $ng "$v"
  [ "$no" != 0 ] && comm -13 /tmp/.aw.obase.$$ /tmp/.aw.o${LAWTAG:-law}.$$ | sed 's/^/     NEW-OURS  /'
  [ "$ng" != 0 ] && comm -13 /tmp/.aw.gbase.$$ /tmp/.aw.g${LAWTAG:-law}.$$ | sed 's/^/     NEW-GOLD  /'
  rm -f /tmp/.aw.o*.$$ /tmp/.aw.g*.$$ /tmp/.aw.d*.$$ /tmp/.aw.*r.$$
done
