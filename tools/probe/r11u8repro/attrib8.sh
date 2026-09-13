#!/usr/bin/env bash
# r11u8 — attribute a byte mover LINE BY LINE, order-blind, and score each
# changed line against GOLDEN.  Dump paths embed the workdir, so both sides are
# path-normalised before the sort.
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
A=${1:?patched workdir}; B=${2:?pristine workdir}; REL=${3:?relative db path}
norm() { sed -e "s|$1||g" -e 's|/tmp/[A-Za-z0-9_]*||g'; }
ga=$(grep -o 'golden cache hit [^)]*' "$A/$(dirname "$REL")/cmds.txt" | sed 's/golden cache hit //')
gf="$ga/golden.uhdm"; [ -f "$gf" ] || gf=$(ls "$ga"/*.uhdm 2>/dev/null | head -1)
$D "$A/$REL" 2>/dev/null | norm "$A" | sort > /tmp/r11u8_at_a.txt
$D "$B/$REL" 2>/dev/null | norm "$B" | sort > /tmp/r11u8_at_b.txt
$D "$gf"     2>/dev/null | norm "$(dirname "$gf")" | sort > /tmp/r11u8_at_g.txt
echo "== $REL"
diff /tmp/r11u8_at_b.txt /tmp/r11u8_at_a.txt | grep '^[<>]' > /tmp/r11u8_at_d.txt
echo "   order-blind changed lines: $(wc -l < /tmp/r11u8_at_d.txt)"
# score: a line ADDED by the patch that golden also has = TO-GOLDEN;
#        a line REMOVED that golden has = AWAY-GOLDEN.
to=0; away=0; still=0
while IFS= read -r l; do
  s=${l:0:1}; t=${l:2}
  if grep -qxF "$t" /tmp/r11u8_at_g.txt; then
    [ "$s" = ">" ] && to=$((to+1)) || away=$((away+1))
  else
    still=$((still+1))
  fi
done < /tmp/r11u8_at_d.txt
echo "   TO-GOLDEN=$to  AWAY-GOLDEN=$away  NOT-IN-GOLDEN(either side)=$still"
sed 's/^/     /' /tmp/r11u8_at_d.txt | head -60
exit 0
