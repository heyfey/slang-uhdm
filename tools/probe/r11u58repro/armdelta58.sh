#!/bin/bash
# r11u58 — the NEWLY-UNMATCHED sets between two tags of one arm: lines that
# were matched to golden under BASE and are not under PAT (an away-move), and
# the reverse (a toward-move).  Order-blind, path-normalised.
set -u
D=${1:?arm}
n(){ sed -e "s#$D/##g" -e 's#/home/heyfey/[^ ,)]*/##g' -e 's/, id:[0-9]*//g' "$1" | sort; }
n $D/gold.base.dump > /tmp/r11u58_dl.gb; n $D/ours.base.dump > /tmp/r11u58_dl.ob
n $D/gold.pat.dump  > /tmp/r11u58_dl.gp; n $D/ours.pat.dump  > /tmp/r11u58_dl.op
cmp -s /tmp/r11u58_dl.gb /tmp/r11u58_dl.gp || echo "  WARN golden differs between tags"
diff /tmp/r11u58_dl.gb /tmp/r11u58_dl.ob | grep '^>' | sort > /tmp/r11u58_dl.oob
diff /tmp/r11u58_dl.gp /tmp/r11u58_dl.op | grep '^>' | sort > /tmp/r11u58_dl.oop
diff /tmp/r11u58_dl.gb /tmp/r11u58_dl.ob | grep '^<' | sort > /tmp/r11u58_dl.gob
diff /tmp/r11u58_dl.gp /tmp/r11u58_dl.op | grep '^<' | sort > /tmp/r11u58_dl.gop
echo "$(basename $D) NEW-ours-only=$(comm -13 /tmp/r11u58_dl.oob /tmp/r11u58_dl.oop | wc -l) GONE-ours-only=$(comm -23 /tmp/r11u58_dl.oob /tmp/r11u58_dl.oop | wc -l) NEW-golden-only=$(comm -13 /tmp/r11u58_dl.gob /tmp/r11u58_dl.gop | wc -l) GONE-golden-only=$(comm -23 /tmp/r11u58_dl.gob /tmp/r11u58_dl.gop | wc -l)"
