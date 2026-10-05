# (v11u245: copied from r11u245repro/drivers)
#!/bin/bash
# (r11u245: written from r11u243repro/drivers/grid.sh)
# grid.sh <outfile> [dirs...]: every case under cases/ and decode/ (or the given case dirs) in both views on pristine,
# law, law + R11U245_OFF and law + each switch; one line per run (case.sh's line, exit code included).
# Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "grid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; shift; : > $out
SW="R11U245_UNITPREDEF_OFF R11U245_UNITPREDEFAOA_OFF R11U245_UNITARR_OFF R11U245_UNITLAWS_OFF R11U245_UNITRETLOC_OFF R11U245_UNITREALTD_OFF"
L=${@:-$(cd $H && ls -d cases/*/* decode/*/* | sort | sed "s#^#$H/#")}
for c in $L; do
  for el in 0 1; do
    EL=$el $H/drivers/case.sh $c pristine $B/pristine >> $out
    EL=$el $H/drivers/case.sh $c law ${LAWBIN:-$B/law} >> $out
    EL=$el $H/drivers/case.sh $c lawOFF ${LAWBIN:-$B/law} R11U245_OFF=1 >> $out
    for s in $SW; do EL=$el $H/drivers/case.sh $c "law-$s" ${LAWBIN:-$B/law} $s=1 >> $out; done
  done
done
