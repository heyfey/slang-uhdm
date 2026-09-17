#!/usr/bin/env bash
# v11u59 away-move test: per arm, lines golden has that we still lack (golden-only)
# and lines we emit that golden lacks (ours-only), order-blind, before vs after.
set -u
D=$1
n() { sed -e 's#/tmp/[^ ,)]*##g' -e 's/, id:[0-9]*//g' "$1" | sort; }
n $D/gold.pris.dump > /tmp/v11u59_d.gb; n $D/ours.pris.dump > /tmp/v11u59_d.ob
n $D/gold.pat.dump  > /tmp/v11u59_d.gp; n $D/ours.pat.dump  > /tmp/v11u59_d.op
cmp -s /tmp/v11u59_d.gb /tmp/v11u59_d.gp || echo "  WARN golden differs between tags"
diff /tmp/v11u59_d.gb /tmp/v11u59_d.ob | grep '^>' | sort > /tmp/v11u59_d.oob
diff /tmp/v11u59_d.gp /tmp/v11u59_d.op | grep '^>' | sort > /tmp/v11u59_d.oop
diff /tmp/v11u59_d.gb /tmp/v11u59_d.ob | grep '^<' | sort > /tmp/v11u59_d.gob
diff /tmp/v11u59_d.gp /tmp/v11u59_d.op | grep '^<' | sort > /tmp/v11u59_d.gop
echo "$(basename $D) NEWoursonly=$(comm -13 /tmp/v11u59_d.oob /tmp/v11u59_d.oop | wc -l) GONEoursonly=$(comm -23 /tmp/v11u59_d.oob /tmp/v11u59_d.oop | wc -l) NEWgoldenonly=$(comm -13 /tmp/v11u59_d.gob /tmp/v11u59_d.gop | wc -l) GONEgoldenonly=$(comm -23 /tmp/v11u59_d.gob /tmp/v11u59_d.gop | wc -l)"
comm -13 /tmp/v11u59_d.gob /tmp/v11u59_d.gop | sed 's/^/    NEWGOLDONLY /'
